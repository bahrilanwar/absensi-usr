// ignore_for_file: missing_return

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'sys_config.dart';

String appPackageName = 'id.ptipd_usr.absensi_usr2';

String formatDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

String dayName(int index) {
  switch (index) {
    case 1:
      return 'Senin';
      break;

    case 2:
      return 'Selasa';
      break;

    case 3:
      return 'Rabu';
      break;

    case 4:
      return 'Kamis';
      break;

    case 5:
      return 'Jum\'at';
      break;

    case 6:
      return 'Sabtu';
      break;

    default:
      return index.toString();
      break;
  }
}

String dateIndo(String date) {
  List<String> dateArr = date.split(', ');
  String hari = dateArr[0], bulanTanggal = dateArr[1], tahun = dateArr[2];
  List<String> bulanTanggalArr = bulanTanggal.split(' ');
  String bulan = bulanTanggalArr[0], tanggal = bulanTanggalArr[1];
  switch (hari) {
    case 'Monday':
      hari = 'Senin';
      break;

    case 'Tuesday':
      hari = 'Selasa';
      break;

    case 'Wednesday':
      hari = 'Rabu';
      break;

    case 'Thursday':
      hari = 'Kamis';
      break;

    case 'Friday':
      hari = 'Jum\'at';
      break;

    case 'Saturday':
      hari = 'Sabtu';
      break;

    case 'Sunday':
      hari = 'Minggu';
      break;
  }

  switch (bulan) {
    case 'January':
      bulan = 'Januari';
      break;

    case 'February':
      bulan = 'Februari';
      break;

    case 'March':
      bulan = 'Maret';
      break;

    case 'May':
      bulan = 'Mei';
      break;

    case 'June':
      bulan = 'Juni';
      break;

    case 'July':
      bulan = 'Juli';
      break;

    case 'August':
      bulan = 'Agustus';
      break;

    case 'September':
      bulan = 'September';
      break;

    case 'October':
      bulan = 'Oktober';
      break;

    case 'December':
      bulan = 'Desember';
      break;
  }

  return "$hari, $tanggal $bulan $tahun";
}

String dateIndoShort(String date) {
  List<String> dateArr = date.split(', ');
  String hari = dateArr[0], bulanTanggal = dateArr[1], tahun = dateArr[2];
  List<String> bulanTanggalArr = bulanTanggal.split(' ');
  String bulan = bulanTanggalArr[0], tanggal = bulanTanggalArr[1];
  switch (hari) {
    case 'Monday':
      hari = 'Senin';
      break;

    case 'Tuesday':
      hari = 'Selasa';
      break;

    case 'Wednesday':
      hari = 'Rabu';
      break;

    case 'Thursday':
      hari = 'Kamis';
      break;

    case 'Friday':
      hari = 'Jum\'at';
      break;

    case 'Saturday':
      hari = 'Sabtu';
      break;

    case 'Sunday':
      hari = 'Minggu';
      break;
  }

  switch (bulan) {
    case 'January':
      bulan = 'Jan';
      break;

    case 'February':
      bulan = 'Feb';
      break;

    case 'March':
      bulan = 'Mar';
      break;

    case 'May':
      bulan = 'Mei';
      break;

    case 'June':
      bulan = 'Jun';
      break;

    case 'July':
      bulan = 'Jul';
      break;

    case 'August':
      bulan = 'Agu';
      break;

    case 'September':
      bulan = 'Sep';
      break;

    case 'October':
      bulan = 'Okt';
      break;

    case 'November':
      bulan = 'Nov';
      break;

    case 'December':
      bulan = 'Des';
      break;
  }

  return "$tanggal $bulan $tahun";
}

void alert(
    {BuildContext context, String title: 'Perhatian', List<Widget> children}) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          titlePadding: EdgeInsets.fromLTRB(12, 24.0, 24.0, 0.0),
          contentPadding: EdgeInsets.all(12),
          title: Text(title),
          children: children,
        );
      });
}

void callC3(BuildContext context) async {
  String url = 'whatsapp://send?phone=$helpdeskPhone';
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    alert(context: context, children: [
      Text(
          'Silahkan hubungi C3 melalui aplikasi whatsapp ke nomor : $helpdeskPhone')
    ]);
  }
}

void alertAct(
    {BuildContext context,
    bool barrierDismissible: true,
    String title: 'Perhatian',
    Widget content,
    List<Widget> actions}) {
  showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.fromLTRB(12, 24.0, 24.0, 0.0),
          contentPadding: EdgeInsets.all(12),
          title: Text(title),
          content: content,
          actions: actions,
        );
      });
}

extension StringExt on String {
  String showMax(int max) {
    if (this.length > max) {
      return this.substring(0, max) + '...';
    }
    return this;
  }
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

Widget dropDownField(
    String label, String assetPath, TextEditingController controller,
    {bool isRequired: true, Icon icon}) {
  return FutureBuilder(
    future: parseJsonFromAssets(assetPath),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text("Error : ${snapshot.error}");
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return LinearProgressIndicator();
      }

      List<String> data = snapshot.data;
      print(snapshot.data);
      return (controller.text.isEmpty)
          ? DropdownButtonFormField(
              decoration: InputDecoration(labelText: label, icon: icon),
              validator: (value) {
                if (isRequired) {
                  if (value == null) {
                    print('dropdown $label == $value');
                    return "$label wajib dipilih";
                  }
                  return null;
                }
              },
              items: data.map((value) {
                String nama = (value.isNotEmpty) ? value : 'Tidak Ada';
                return DropdownMenuItem(child: Text(nama), value: value);
              }).toList(),
              onChanged: (value) {
                controller.text = value;
              },
            )
          : DropdownButtonFormField(
              value: controller.text,
              decoration: InputDecoration(labelText: label, icon: icon),
              validator: (value) {
                if (isRequired) {
                  if (value == null) {
                    print('dropdown $label == $value');
                    return "$label wajib dipilih";
                  }
                  return null;
                }
              },
              items: data.map((value) {
                String nama = (value.isNotEmpty) ? value : 'Tidak Ada';
                return DropdownMenuItem(child: Text(nama), value: value);
              }).toList(),
              onChanged: (value) {
                controller.text = value;
              },
            );
    },
  );
}

Future<List<String>> parseJsonFromAssets(String assetPath) async {
  String jsonStr = await rootBundle.loadString(assetPath);
  List<String> jsonObj = List.from(json.decode(jsonStr));
  return jsonObj;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

// fungsi untuk cek apakah point di dalam poligon?
bool checkIfValidMarker(LatLng tap, List<LatLng> vertices) {
  int intersectCount = 0;
  for (int j = 0; j < vertices.length - 1; j++) {
    if (rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
      intersectCount++;
    }
  }

  return ((intersectCount % 2) == 1); // odd = inside, even = outside;
}

bool rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
  double aY = vertA.latitude;
  double bY = vertB.latitude;
  double aX = vertA.longitude;
  double bX = vertB.longitude;
  double pY = tap.latitude;
  double pX = tap.longitude;

  if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
    return false; // a and b can't both be above or below pt.y, and a or
    // b must be east of pt.x
  }

  double m = (aY - bY) / (aX - bX); // Rise over run
  double bee = (-aX) * m + aY; // y = mx + b
  double x = (pY - bee) / m; // algebra is neat!

  return x > pX;
}

extension DateTimeExt on DateTime {
  bool isWorkingDay() {
    bool isSeninSdJumat = this.weekday <= SysConfig.listJamKerja(null).length;
    bool isTanggalMerah = false;
    SysConfig.listTanggalMerah().forEach((tgl) {
      if (this.isSameDate(tgl)) isTanggalMerah = true;
    });
    print('this : ${DateFormat('yyyy-MM-dd').format(this)}');
    print('isSeninSdJumat : $isSeninSdJumat');
    print('isTanggalMerah : $isTanggalMerah');
    return (isSeninSdJumat && !isTanggalMerah);
  }

  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}
