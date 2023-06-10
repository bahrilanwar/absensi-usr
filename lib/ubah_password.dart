// ignore_for_file: missing_return

import 'dart:convert';

import 'package:absensi_usr/app_log.dart';
import 'package:absensi_usr/staff.dart';
import 'package:absensi_usr/login.dart';
import 'package:absensi_usr/session.dart';
import 'package:absensi_usr/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UbahPassword extends StatefulWidget {
  final SharedPreferences prefs;

  UbahPassword({@required this.prefs});

  @override
  _UbahPasswordState createState() => _UbahPasswordState();
}

class _UbahPasswordState extends State<UbahPassword> {
  final _formKey = GlobalKey<FormState>();
  Staff staff;
  bool _isSuccess = false;

  TextEditingController oldPassCont = TextEditingController();
  TextEditingController passCont = TextEditingController();
  TextEditingController passCont2 = TextEditingController();

  Widget _textField(
      TextInputType type, String label, TextEditingController controller,
      {readonly: false}) {
    ThemeData theme = Theme.of(context);
    return TextFormField(
      style: (readonly) ? TextStyle(color: theme.disabledColor) : null,
      readOnly: readonly,
      obscureText: (type == TextInputType.visiblePassword) ? true : false,
      keyboardType: type,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value.isEmpty) {
          return "$label wajib diisi";
        }

        if (type == TextInputType.visiblePassword && value.length < 5) {
          return "Minimal 5 karakter";
        }

        if (type == TextInputType.visiblePassword &&
            controller == passCont2 &&
            controller.text != passCont.text) {
          return "Kombinasi password tidak cocok";
        }
        return null;
      },
      controller: controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('staff')
        .doc(widget.prefs.getString(NO_INDUK));

    Stream<DocumentSnapshot> _streamStaff = reference.snapshots();

    return AlertDialog(
      title: Text('Ubah Password'),
      content: StreamBuilder<DocumentSnapshot>(
        stream: _streamStaff,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          print('no induk : ${widget.prefs.getString(NO_INDUK)}');
          print('datanya ada : ${snapshot.data.exists}');

          if (snapshot.data.exists) {
            staff = Staff.fromJson(snapshot.data.data());
          }

          return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _textField(TextInputType.visiblePassword,
                        'Password Lama atau Token dari Email', oldPassCont),
                    _textField(TextInputType.visiblePassword, 'Password Baru',
                        passCont),
                    _textField(TextInputType.visiblePassword,
                        'Ulangi Password Baru', passCont2),
                  ],
                ),
              ));
        },
      ),
      actions: [
        StreamBuilder<DocumentSnapshot>(
            stream: _streamStaff,
            builder: (context, snapshot) {
              _isSuccess = snapshot.hasData && snapshot.data.exists;
              return ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.pinkAccent)),
                  onPressed: (_isSuccess) ? () => _submit(reference) : null,
                  child: Text(_isSuccess ? 'SIMPAN' : 'MEMUAT...'));
            }),
        TextButton(
            onPressed: () => Navigator.of(context).pop(), child: Text('BATAL'))
      ],
    );
  }

  Future<bool> _submit(DocumentReference reference) async {
    if (_formKey.currentState.validate()) {
      try {
        // check internet connection
        Dio dio = new Dio();
        await dio.get('https://google.com');

        if (staff.password !=
            sha1.convert(utf8.encode(oldPassCont.text)).toString()) {
          throw ('Password lama atau token yang dimasukkan salah');
        }

        reference.update(<String, dynamic>{
          'password': sha1.convert(utf8.encode(passCont.text)).toString(),
          'time_update': FieldValue.serverTimestamp(),
          'app_log': AppLog.jsonFormatted
        });

        DocumentSnapshot staffUpdated = await reference.get();
        clearSession();
        createSession(staffUpdated.data());
        Navigator.of(context).pop();
        alert(
          context: context,
          title: 'Berhasil',
          children: [Text('Password berhasil diperbarui')],
        );
      } catch (e) {
        alert(context: context, title: 'Kesalahan', children: [
          Text(
            (e is DioError)
                ? 'Periksa koneksi internet anda lalu coba lagi'
                : e.toString(),
            style: TextStyle(fontSize: 18),
          )
        ]);
        return false;
      }
    }
  }
}
