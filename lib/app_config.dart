import 'dart:io';

import 'package:absensi_usr/sys_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AppConfig {
  final String androidAppVersion;
  final String iosAppVersion;
  final bool isPlayStoreReady;
  final bool wfhStatus;

  String get appConfigVer {
    String appPlatform = getAppPlatform();
    if (appPlatform == 'android') {
      return androidAppVersion;
    } else if (appPlatform == 'ios') {
      return iosAppVersion;
    } else {
      return null; // TODO: ganti dengan versi terbaru web yang ada di app_config.json
    }
  }

  bool get isAppNewest {
    // return true; // SEGERA MATIKAN, FOR DEBUG ONLY
    String appPlatform = getAppPlatform();
    if (appPlatform == 'android') {
      return androidAppVersion == androidAppVer;
    } else if (appPlatform == 'ios') {
      return iosAppVersion == iOSAppVer;
    } else {
      return null; // TODO: ganti dengan versi terbaru web yang ada di app_config.json
    }
  }

  AppConfig(
      {@required this.androidAppVersion,
        @required this.iosAppVersion,
        @required this.isPlayStoreReady,
        @required this.wfhStatus});

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
        androidAppVersion: json['android_app_version'],
        iosAppVersion: json['ios_app_version'],
        isPlayStoreReady: json['is_play_store_ready'],
        wfhStatus: json['is_wfh_available'],);
  }
}

Future<AppConfig> getAppConfig() async {
  Response response;
  Dio dio = new Dio();
  // String route = 'https://presensia.uin-suska.ac.id/api/app_config.json';
  String route =
      'https://firebasestorage.googleapis.com/v0/b/absensi-usr-a665b.appspot.com/o/config%2Fapp_config.json?alt=media';

  try {
    response = await dio.get(route);

    if (response.statusCode == 200) {
      print('berhasil hit $route');
      // print(AppConfig().androidAppVersion.toString());
      return AppConfig.fromJson(response.data);
    } else {
      print(
          'gagal hit $route, response code : ${response.statusCode}, message : ${response.statusMessage}');
      throw Exception(response.statusCode);
    }
  } catch (error, stacktrace) {
    if (error is DioError) {
      print(error.error);
    }
    print("Exception occured: $error stackTrace: $stacktrace");
    return null;
  }
}
