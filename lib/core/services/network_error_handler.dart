import 'dart:async';
import 'dart:io';

/// Utility to translate various network exceptions into user-friendly Indonesian errors.
class NetworkErrorHandler {
  NetworkErrorHandler._();

  /// Translates an exception or error object into a descriptive string.
  static String getFriendlyMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Koneksi Timeout (Waktu habis). Pastikan server backend di laptop sudah menyala dan HP Anda terhubung ke jaringan Wi-Fi yang sama.';
    }

    if (error is SocketException) {
      final message = error.message.toLowerCase();
      final osErrorMsg = error.osError?.message.toLowerCase() ?? '';
      final errorCode = error.osError?.errorCode ?? 0;

      if (message.contains('connection refused') || osErrorMsg.contains('connection refused') || errorCode == 111) {
        return 'Koneksi Ditolak (Connection Refused). Server backend Node.js di laptop Anda belum menyala, atau port 5000 tidak diizinkan.';
      }

      if (message.contains('no route to host') || osErrorMsg.contains('no route to host') || errorCode == 113) {
        return 'Host Tidak Dapat Dijangkau (No Route to Host). Pastikan laptop dan HP terhubung ke Wi-Fi yang sama. Periksa apakah laptop Anda menggunakan IP 192.168.100.12. Jika menggunakan Wi-Fi publik, matikan AP Isolation atau gunakan Mobile Hotspot.';
      }

      if (message.contains('network is unreachable') || osErrorMsg.contains('network is unreachable')) {
        return 'Jaringan Tidak Dapat Dijangkau (Network Unreachable). Periksa koneksi internet HP Anda.';
      }

      return 'Koneksi Gagal (Socket Exception). Periksa apakah HP dan laptop Anda berada di Wi-Fi yang sama dan firewall Windows tidak memblokir port 5000 (Node.js).';
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
