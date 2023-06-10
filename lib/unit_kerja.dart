import 'package:absensi_usr/session.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitKerja {
  final String nama;
  final DateTime startLockDown, endLockDown;


  UnitKerja({this.nama, this.startLockDown, this.endLockDown});

  bool isLockdownNow() {
    if (this.startLockDown != null && this.endLockDown != null) {
      DateTime now = DateTime.now();
      if (now.isAfter(this.startLockDown) && now.isBefore(this.endLockDown))
        return true;
    }

    return false;
  }

  factory UnitKerja.fromJson(Map<String, dynamic> json) {
    return UnitKerja(
        nama: json['nama'],
        startLockDown: (["", null, false, 0].contains(json["start_lockdown"])
            ? null
            : DateTime.parse(json['start_lockdown'])),
        endLockDown: (["", null, false, 0].contains(json["end_lockdown"])
            ? null
            : DateTime.parse(json['end_lockdown'])));
  }
}

Future<List<UnitKerja>> getUnitKerjas() async {
  Response response;
  Dio dio = new Dio();
  String route =
      'https://firebasestorage.googleapis.com/v0/b/absensi-usr-a665b.appspot.com/o/config%2Funit_kerja.json?alt=media';

  try {
    print('hit route $route');
    response = await dio.get(route);
    if (response.statusCode == 200) {
      List<UnitKerja> unitKerjas =
          (response.data as List).map((d) => UnitKerja.fromJson(d)).toList();
      return unitKerjas;
    } else {
      print(
          'failed hit $route : ${response.statusCode}, message : ${response.statusMessage}');
      throw Exception(response.statusCode);
    }
  } catch (error, stacktrace) {
    print("Exception occured: $error stackTrace: $stacktrace");
    return null;
  }
}

Future<UnitKerja> getMyUnitKerja() async {
  List<UnitKerja> unitKerjas = await getUnitKerjas();
  print('ada ${unitKerjas.length} unit kerja');
  if (unitKerjas == null) {
    throw ('Gagal memuat data unit kerja dari server');
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  UnitKerja unitKerja = unitKerjas
      .firstWhere((element) => element.nama == prefs.getString(UNIT_KERJA));

  if (unitKerja == null) {
    throw ('Tidak ditemukan unit kerja ${prefs.getString(UNIT_KERJA)} di server');
  }

  return unitKerja;
}
