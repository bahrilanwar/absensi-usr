// ignore_for_file: unused_import

import 'dart:io';

import 'package:absensi_usr/sys_config.dart';
import 'package:flutter/material.dart';

class AppLog {
  final String type, version;

  AppLog({@required this.type, @required this.version});

  factory AppLog.fromJson(Map<String, dynamic> json) {
    return AppLog(type: json['type'], version: json['version']);
  }

  static Map<String, dynamic> get jsonFormatted {
    return {'type': getAppPlatform(), 'version': getAppVer()};
  }
}
