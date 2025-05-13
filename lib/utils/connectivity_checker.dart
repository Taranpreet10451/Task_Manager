import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class ConnectivityChecker {
  final Dio _dio = Dio();
  
  /// Checks if the device is connected to the internet
  Future<bool> isConnected() async {
    try {
      if (kIsWeb) {
        // For web platforms, try to make a lightweight request
        final response = await _dio.get('https://www.google.com', 
          options: Options(
            validateStatus: (_) => true,
            sendTimeout: const Duration(seconds: 3),
            receiveTimeout: const Duration(seconds: 3),
          )
        );
        return response.statusCode == 200;
      } else {
        // For non-web platforms, use InternetAddress.lookup
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      }
    } catch (e) {
      return false;
    }
  }
} 