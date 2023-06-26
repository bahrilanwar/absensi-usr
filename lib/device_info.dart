// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:absensi_usr/imei.dart';
import 'package:absensi_usr/util.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:device_information/device_information.dart';

Future<Map<String, dynamic>> getDeviceInfo() async {
  Map<String, dynamic> deviceData;
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  try {
    if (Platform.isAndroid) {
      print('deviceData : ${deviceData.toString()}');
      deviceData =
          await _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      print('deviceData : ${deviceData.toString()}');
    } else if (Platform.isIOS) {
      deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    } else {
      deviceData = _readOtherDeviceInfo();
    }
  } on PlatformException {
    deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
  }

  return deviceData;
}

Map<String, dynamic> _readOtherDeviceInfo() {
  return <String, dynamic>{'platform': Platform.operatingSystem};
}

Future<Map<String, dynamic>> _readAndroidBuildData(
    AndroidDeviceInfo build) async {
  String platformImei = await DeviceInformation.deviceIMEINumber;

  // List<String> multiImei = await ImeiImsiPlugin.getImeiMulti();

  // String idunique = await ImeiImsiPlugin.getId();
  bool isValidIMEI =
      IMEI.isValidIMEI(isNumeric(platformImei) ? int.parse(platformImei) : -1);

  return <String, dynamic>{
    /*
    Sementara disable imei record
    */
    // 'imei': platformImei,
    // 'imei_equal': idunique,
    'platform': Platform.operatingSystem,
    'is_physical_device': isValidIMEI ?? build.isPhysicalDevice,
    'version_sdk_int': build.version.sdkInt,
    'version_security_patch': build.version.securityPatch,
    'brand': build.brand,
    'device': build.device,
    'manufacturer': build.manufacturer,
    'model': build.model,
    'product': build.product,
    'supported_abis': build.supportedAbis,
    'type': build.type,
    'android_id': build.androidId,
    'system_features': build.systemFeatures,
  };
}

Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
  return <String, dynamic>{
    'platform': Platform.operatingSystem,
    'is_physical_device': data.isPhysicalDevice,
    'name': data.name,
    'system_name': data.systemName,
    'system_version': data.systemVersion,
    'model': data.model,
    'localized_model': data.localizedModel,
    'identifier_for_vendor': data.identifierForVendor,
    'utsname_sysname:': data.utsname.sysname,
    'utsname_nodename:': data.utsname.nodename,
    'utsname_release:': data.utsname.release,
    'utsname_version:': data.utsname.version,
    'utsname_machine:': data.utsname.machine,
  };
}
