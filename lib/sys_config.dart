import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'presensi.dart';

String appName = 'Presensia';
String androidAppVer = 'v23.08.22';
String iOSAppVer = 'v23.07.21';
String webAppVer = 'v11.03.21';
String appIconPath = 'assets/images/logo.png';
String appLegalese = 'Developed by ©PTIPD 2021';
String helpdeskPhone = '+628117627773';

MasterJamKerja getMasterJamkerja(DateTime dateTime, Presensi presensi) {
  return SysConfig.listJamKerja(presensi?.timeCreate?.toDate()).firstWhere(
      (jamKerja) => jamKerja.weekday == dateTime.weekday,
      orElse: () => null);
}

String getAppPlatform() {
  if (kIsWeb) {
    return "web";
  } else {
    return Platform.operatingSystem?.toLowerCase();
  }
}

String getAppVer() {
  if (Platform.isAndroid) {
    return androidAppVer;
  } else if (Platform.isIOS) {
    return iOSAppVer;
  } else {
    return webAppVer;
  }
}

class SysConfig {
  static List<MasterJamKerja> listJamKerja(DateTime dateTime) {
    dateTime = dateTime ?? DateTime.now();

    // setup jam kerja
    final List<MasterJamKerja> jamKerjas = [
      MasterJamKerja(
          weekday: 1,
          jamMasuk:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 7, 30),
          jamPulang:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 16, 00)),
      MasterJamKerja(
          weekday: 2,
          jamMasuk:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 7, 30),
          jamPulang:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 16, 00)),
      MasterJamKerja(
          weekday: 3,
          jamMasuk:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 7, 30),
          jamPulang:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 16, 00)),
      MasterJamKerja(
          weekday: 4,
          jamMasuk:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 7, 30),
          jamPulang:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 16, 00)),
      MasterJamKerja(
          weekday: 5,
          jamMasuk:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 7, 30),
          jamPulang:
              DateTime(dateTime.year, dateTime.month, dateTime.day, 16, 30)),
    ];

    return jamKerjas;
  }

  //setup tanggal merah
  static List<dynamic> listTanggalMerah() {
    final List<dynamic> list = [
      DateTime(2021, 01, 01),
      DateTime(2021, 02, 12),
      DateTime(2021, 03, 11),
      DateTime(2021, 03, 12),
      DateTime(2021, 03, 14),
      DateTime(2021, 04, 02),
      DateTime(2021, 05, 13),
      DateTime(2021, 05, 14),
      DateTime(2021, 05, 26),
      DateTime(2021, 06, 01),
      DateTime(2021, 07, 20),
      DateTime(2021, 08, 10),
      DateTime(2021, 08, 17),
      DateTime(2021, 10, 19),
      DateTime(2021, 12, 24),
      DateTime(2021, 12, 27),
    ];

    return list;
  }
}

class MasterJamKerja {
  final int weekday;
  final DateTime jamMasuk, jamPulang;

  MasterJamKerja({this.weekday, this.jamMasuk, this.jamPulang});
}

// Future<List<WaktuKerja>> waktuKerja(int array) async {
//   var waktuKerjas = await rootBundle;
//   // print(int.parse(waktuKerjas[0].waktuMasuk));
//   String jsonStr = await rootBundle.loadString(assetPath);
//   List<WaktuKerja> jsonObj = List.from(json.decode(waktuKerjas));
//   return jsonObj;
// }


