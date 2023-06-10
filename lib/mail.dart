import 'package:absensi_usr/util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

Future<bool> sendMailResetPass(BuildContext context, String toEmail,
    String toName, String tokenReset) async {
  Response response;
  Dio dio = new Dio();
  String route = 'https://api.mailjet.com/v3.1/send';

  try {
    Options options = Options(headers: {
      'Content-Type': 'application/json',
      'Authorization':
          'Basic NzkwOTAyZDljNjIwMWFjOTg1ZjJjZDJkM2NiY2NiZmM6NzA2ZGMyOGM2ZWUwMjRhZDkzMjNhYWQ4NzU5Y2I4N2Y='
    });

    Map<String, dynamic> data = {
      "Messages": [
        {
          "From": {"Email": "absensi@uin-suska.ac.id", "Name": "Presensia"},
          "To": [
            {"Email": "$toEmail", "Name": "$toName"}
          ],
          "Subject": "Password baru anda",
          "TextPart": "Reset password anda berhasil dilakukan.",
          "HTMLPart":
              "<h3>Halo $toName, silahkan login menggunakan password <b>$tokenReset</b></h3><br />Terimakasih dan selamat bekerja",
          "CustomID": "ResetPassword"
        }
      ]
    };

    response = await dio.post(route, options: options, data: data);
    if (response.statusCode == 200) {
      print('berhasil kirim email');
      return true;
    } else {
      print(
          'gagal kirim email, response code : ${response.statusCode}, message : ${response.statusMessage}');
      throw Exception(response.statusCode);
    }
  } catch (error, stacktrace) {
    print("Exception occured: $error stackTrace: $stacktrace");
    alert(context: context, children: [
      Text('Gagal mengirimkan email ke $toEmail'),
      Text(error.toString()),
      Text(stacktrace.toString())
    ]);
    return false;
  }
}
