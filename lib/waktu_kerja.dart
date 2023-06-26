import 'package:dio/dio.dart';

class WaktuKerja {
  final String hari, waktuMasukM, waktuKeluarM, waktuMasukS, waktuKeluarS;

  WaktuKerja(
      {this.hari,
      this.waktuMasukM,
      this.waktuKeluarM,
      this.waktuMasukS,
      this.waktuKeluarS});

  factory WaktuKerja.fromJson(Map<String, dynamic> json) {
    return WaktuKerja(
        hari: json['hari'],
        waktuMasukM: json["jam_masuk_m"],
        waktuKeluarM: json["jam_keluar_m"],
        waktuMasukS: json["jam_masuk_s"],
        waktuKeluarS: json["jam_keluar_"]);
  }
}

// Future<List<WaktuKerja>> getWaktuKerja(x) async {
//   Response response;
//   Dio dio = new Dio();
//   // String route = 'https://presensia.uin-suska.ac.id/api/app_config.json';
//   String route =
//       'https://firebasestorage.googleapis.com/v0/b/absensi-usr-a665b.appspot.com/o/config%2Fwaktu_kerja.json?alt=media';
//
//   try {
//     response = await dio.get(route);
//
//     if (response.statusCode == 200) {
//       print('berhasil hit $route');
//       List<WaktuKerja> waktuKerjas =
//       (response.data as List).map((d) => WaktuKerja.fromJson(d)).toList();
//       // print(AppConfig().androidAppVersion.toString());
//       var waktuKerja = waktuKerjas;
//       print(waktuKerja);
//       return waktuKerja;
//     } else {
//       print(
//           'gagal hit $route, response code : ${response.statusCode}, message : ${response.statusMessage}');
//       throw Exception(response.statusCode);
//     }
//   } catch (error, stacktrace) {
//     if (error is DioError) {
//       print(error.error);
//     }
//     print("Exception occured: $error stackTrace: $stacktrace");
//     return null;
//   }
// }

Future<List<WaktuKerja>> getWaktuKerja() async {
  Response response;
  Dio dio = new Dio();
  String route =
      'https://firebasestorage.googleapis.com/v0/b/absensi-usr-a665b.appspot.com/o/config%2Fwaktu_kerja.json?alt=media';

  try {
    response = await dio.get(route);
    if (response.statusCode == 200) {
      print('berhasil hit $route');
      List<WaktuKerja> waktuKerjas =
          (response.data as List).map((d) => WaktuKerja.fromJson(d)).toList();
      print(waktuKerjas);
      return waktuKerjas;
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

// Future<WaktuKerja> getMyWaktuKerja() async {
//   List<WaktuKerja> waktuKerjas = await getWaktuKerjas();
//   print('ada ${waktuKerjas.length} waktu kerja');
//   // print();
//   if (waktuKerjas == null) {
//     throw ('Gagal memuat data unit kerja dari server');
//   }
//   return waktuKerja;
// }

// Future<WaktuKerja> getMyWaktuKerja() async {
//   MasterJamKerja _MasterJamKerja;
//   List<WaktuKerja> waktuKerjas = await getWaktuKerjas();
//   print('ada ${waktuKerjas.length} waktu kerja');
//   if (waktuKerjas == null) {
//     throw ('Gagal memuat data unit kerja dari server');
//   }
//
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   WaktuKerja waktuKerja = waktuKerjas
//       .firstWhere((element) => element.hari == _MasterJamKerja.weekday.toString());
//   print(waktuKerja);
//
//   if (waktuKerja == null) {
//     throw ('Tidak ditemukan unit kerja ${prefs.getString(_MasterJamKerja.weekday.toString())} di server');
//   }
//   return waktuKerja;
// }
