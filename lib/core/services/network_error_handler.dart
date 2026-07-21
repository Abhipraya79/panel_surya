import 'dart:async';
import 'dart:io';
import 'package:panel_surya/core/constants/app_config.dart';

/// Utility to translate various network exceptions into user-friendly Indonesian errors.
class NetworkErrorHandler {
  NetworkErrorHandler._();

  /// Translates an exception or error object into a descriptive string.
  static String getFriendlyMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Koneksi Timeout (Waktu habis). Periksa koneksi internet Anda atau pastikan server backend dapat dihubungi.';
    }

    if (error is SocketException) {
      final message = error.message.toLowerCase();
      final osErrorMsg = error.osError?.message.toLowerCase() ?? '';
      final errorCode = error.osError?.errorCode ?? 0;

      if (message.contains('connection refused') || osErrorMsg.contains('connection refused') || errorCode == 111) {
        return 'Koneksi Ditolak (Connection Refused). Hubungi administrator jika server backend mati.';
      }

      if (message.contains('no route to host') || osErrorMsg.contains('no route to host') || errorCode == 113) {
        final uri = Uri.tryParse(AppConfig.baseUrl);
        final host = uri?.host ?? 'panelcare.allvvnt.my.id';
        return 'Host Tidak Dapat Dijangkau (No Route to Host). Periksa koneksi internet Anda dan pastikan server $host dapat diakses.';
      }

      if (message.contains('network is unreachable') || osErrorMsg.contains('network is unreachable')) {
        return 'Jaringan Tidak Dapat Dijangkau (Network Unreachable). Periksa koneksi internet HP Anda.';
      }

      return 'Koneksi Gagal (Socket Exception). Periksa koneksi internet Anda atau pastikan server backend dapat dihubungi.';
    }

    if (error is HttpException) {
      return 'Protokol HTTP bermasalah (HttpException). Gagal berkomunikasi dengan server.';
    }

    if (error is FormatException) {
      return 'Format data tidak sesuai (FormatException). Gagal memproses data JSON dari server.';
    }

    // Remove "Exception: " prefix if present for clean display
    final errorStr = error.toString();
    if (errorStr.startsWith('Exception: ')) {
      return errorStr.substring('Exception: '.length);
    }
    return errorStr;
  }
}
