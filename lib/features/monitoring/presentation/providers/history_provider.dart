import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/telemetry_history_model.dart';
import '../../data/repositories/history_repository.dart';
import '../../../../core/services/network_error_handler.dart';
import '../../../../core/socket/socket_service.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryRepository _repository;
  final SocketService _socket;
  StreamSubscription<Map<String, dynamic>>? _telemetrySub;

  HistoryProvider({
    HistoryRepository? repository,
    SocketService? socket,
  })  : _repository = repository ?? HistoryRepository(),
        _socket = socket ?? SocketService.instance {
    _listenRealtimeTelemetry();
  }

  List<TelemetryHistoryModel> _records = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMoreData = true;
  int _totalData = 0;

  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedInterval = '3 Detik';
  String _searchQuery = '';
  String? _sortBy;
  bool _sortAscending = false;

  List<TelemetryHistoryModel> get records => _records;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;
  int get totalData => _totalData;

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get selectedInterval => _selectedInterval;
  String get searchQuery => _searchQuery;
  String? get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  final int _limit = 50;

  void _listenRealtimeTelemetry() {
    _telemetrySub ??= _socket.telemetryStream.listen((payload) {
      // Create record
      final newRecord = TelemetryHistoryModel.fromJson({
        'temperature': payload['temperature'],
        'airTemp': payload['airTemp'],
        'voltage': payload['voltage'],
        'current': payload['current'],
        'power': payload['power'],
        'dust': payload['dust'],
        'timestamp': payload['receivedAt'] ?? DateTime.now().toIso8601String(),
        'pumpStatus': payload['pump'],
        'wiperStatus': payload['wiper'],
        'systemMode': payload['mode'],
        'deviceStatus': payload['status'],
      });

      // Filter check before adding (if search/date filters apply to new data)
      if (_matchesFilters(newRecord)) {
        _records.insert(0, newRecord); // Prepend for table
        _totalData++;
        notifyListeners();
      }
    });
  }

  bool _matchesFilters(TelemetryHistoryModel r) {
    if (_startDate != null && r.timestamp.isBefore(_startDate!)) return false;
    if (_endDate != null && r.timestamp.isAfter(_endDate!.add(const Duration(days: 1)))) return false;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(r.timestamp).toLowerCase();
      final mode = r.systemMode.toLowerCase();
      final status = r.deviceStatus.toLowerCase();
      if (!dateStr.contains(q) && !mode.contains(q) && !status.contains(q)) {
        return false;
      }
    }
    return true;
  }

  Future<void> loadHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _records.clear();
      _totalData = 0;
    }

    if (!_hasMoreData && !isRefresh) return;

    if (isRefresh) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getHistory(
        limit: _limit,
        page: _currentPage,
        startDate: _startDate,
        endDate: _endDate,
        interval: _selectedInterval,
        search: _searchQuery,
        sortBy: _sortBy,
        sortOrder: _sortBy != null ? (_sortAscending ? 'asc' : 'desc') : null,
      );

      if (result != null) {
        // Fallback frontend filtering and aggregation if backend returned raw data
        var processedList = _applyFrontendFiltersAndAggregation(result);
        
        if (isRefresh) {
          _records = processedList;
        } else {
          _records.addAll(processedList);
        }
        
        _totalData = isRefresh ? _records.length : _totalData + processedList.length;

        // If returned items are less than limit, we reached the end
        if (result.length < _limit) {
          _hasMoreData = false;
        } else {
          _currentPage++;
        }
      } else {
        _hasError = true;
        _errorMessage = 'Gagal memproses data history dari server.';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = NetworkErrorHandler.getFriendlyMessage(e);
      debugPrint('[HISTORY] loadHistory error: $e');
    }

    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  List<TelemetryHistoryModel> _applyFrontendFiltersAndAggregation(List<TelemetryHistoryModel> rawList) {
    // 1. Filter
    var filtered = rawList.where(_matchesFilters).toList();

    // 2. Sort
    if (_sortBy != null) {
      filtered.sort((a, b) {
        int cmp = 0;
        switch (_sortBy) {
          case 'Tanggal':
          case 'Jam':
            cmp = a.timestamp.compareTo(b.timestamp);
            break;
          case 'Suhu Air':
            cmp = a.airTemp.compareTo(b.airTemp);
            break;
          case 'Tegangan':
            cmp = a.voltage.compareTo(b.voltage);
            break;
          case 'Arus':
            cmp = a.current.compareTo(b.current);
            break;
          case 'Daya':
            cmp = a.power.compareTo(b.power);
            break;
          case 'Debu':
            cmp = a.dust.compareTo(b.dust);
            break;
        }
        return _sortAscending ? cmp : -cmp;
      });
    } else {
      // Default sort descending by time for table view
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    // 3. Aggregate by Interval (Fallback)
    // If backend already aggregated, this might be redundant but safe if done carefully
    // Since we don't know if backend supports it, we will just sample the first record of each interval block
    if (_selectedInterval != '3 Detik') {
      int minutes = 0;
      switch (_selectedInterval) {
        case '1 Menit': minutes = 1; break;
        case '5 Menit': minutes = 5; break;
        case '15 Menit': minutes = 15; break;
        case '30 Menit': minutes = 30; break;
        case '1 Jam': minutes = 60; break;
      }
      
      if (minutes > 0) {
        List<TelemetryHistoryModel> aggregated = [];
        String? currentBlock;
        for (var record in filtered) {
          // Normalize time to block start
          int minuteBlock = (record.timestamp.minute / minutes).floor() * minutes;
          String blockKey = '${record.timestamp.year}-${record.timestamp.month}-${record.timestamp.day} ${record.timestamp.hour}:$minuteBlock';
          if (blockKey != currentBlock) {
            aggregated.add(record);
            currentBlock = blockKey;
          }
        }
        return aggregated;
      }
    }

    return filtered;
  }

  void updateFilters({
    DateTime? startDate,
    DateTime? endDate,
    String? interval,
    String? search,
  }) {
    if (startDate != null) _startDate = startDate;
    if (endDate != null) _endDate = endDate;
    if (interval != null) _selectedInterval = interval;
    if (search != null) _searchQuery = search;
    
    loadHistory(isRefresh: true);
  }

  void updateSort(String column) {
    if (_sortBy == column) {
      _sortAscending = !_sortAscending;
    } else {
      _sortBy = column;
      _sortAscending = true; // default asc when clicked
    }
    loadHistory(isRefresh: true);
  }

  // --- EXPORT ---

  Future<void> exportToExcel(BuildContext context) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Monitoring_History'];
      excel.setDefaultSheet('Monitoring_History');
      
      // Header
      sheetObject.appendRow([
        TextCellValue('No'),
        TextCellValue('Tanggal'),
        TextCellValue('Jam'),
        TextCellValue('Suhu Air (°C)'),
        TextCellValue('Tegangan (V)'),
        TextCellValue('Arus (A)'),
        TextCellValue('Daya (W)'),
        TextCellValue('Debu'),
        TextCellValue('Pump'),
        TextCellValue('Wiper'),
        TextCellValue('Mode'),
        TextCellValue('Status'),
      ]);

      for (int i = 0; i < _records.length; i++) {
        final r = _records[i];
        sheetObject.appendRow([
          IntCellValue(i + 1),
          TextCellValue(DateFormat('dd MMM yyyy').format(r.timestamp)),
          TextCellValue(DateFormat('HH:mm:ss').format(r.timestamp)),
          DoubleCellValue(r.airTemp.toDouble()),
          DoubleCellValue(r.voltage.toDouble()),
          DoubleCellValue(r.current.toDouble()),
          DoubleCellValue(r.power.toDouble()),
          DoubleCellValue(r.dust.toDouble()),
          TextCellValue(r.pumpStatus ? 'ON' : 'OFF'),
          TextCellValue(r.wiperStatus ? 'ON' : 'OFF'),
          TextCellValue(r.systemMode),
          TextCellValue(r.deviceStatus),
        ]);
      }

      final dir = await getApplicationDocumentsDirectory();
      final filename = 'PanelCare_Monitoring_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${dir.path}/$filename');
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        await file.writeAsBytes(fileBytes);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil diexport ke: ${file.path}')));
        }
      }
    } catch (e) {
      debugPrint('Export Excel Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengekspor Excel')));
      }
    }
  }

  Future<void> exportToPdf(BuildContext context) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Laporan Monitoring Panel Surya', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text(DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()), style: const pw.TextStyle(fontSize: 12)),
                  ]
                )
              ),
              pw.SizedBox(height: 10),
              pw.Text('Filter Aktif: Interval $_selectedInterval | Total Data: $_totalData'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['No', 'Tanggal', 'Jam', 'Suhu\n(°C)', 'Tegangan\n(V)', 'Arus\n(A)', 'Daya\n(W)', 'Pump', 'Wiper', 'Mode', 'Status'],
                data: List<List<String>>.generate(_records.length, (i) {
                  final r = _records[i];
                  return [
                    '${i + 1}',
                    DateFormat('dd/MM/yyyy').format(r.timestamp),
                    DateFormat('HH:mm').format(r.timestamp),
                    r.airTemp.toStringAsFixed(3),
                    r.voltage.toStringAsFixed(3),
                    r.current.toStringAsFixed(3),
                    r.power.toStringAsFixed(3),
                    r.pumpStatus ? 'ON' : 'OFF',
                    r.wiperStatus ? 'ON' : 'OFF',
                    r.systemMode,
                    r.deviceStatus,
                  ];
                }),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.center,
              ),
              pw.SizedBox(height: 20),
              pw.Footer(
                title: pw.Text('Generated by Panel Care App', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              ),
            ];
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final filename = 'PanelCare_Monitoring_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(await pdf.save());
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil diexport ke: ${file.path}')));
      }
    } catch (e) {
      debugPrint('Export PDF Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengekspor PDF')));
      }
    }
  }

  @override
  void dispose() {
    _telemetrySub?.cancel();
    super.dispose();
  }
}

