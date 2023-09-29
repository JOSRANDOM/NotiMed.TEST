// ignore_for_file: unused_local_variable

import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

void main() async {
  final String deviceInfo = await getDeviceInfo();
  print('Mi dispositivo es: $deviceInfo');
}

Future<String> getDeviceInfo() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  try {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    }
    return 'Desconocido';
  } catch (e) {
    return 'Error';
  }
}
