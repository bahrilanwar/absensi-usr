// ignore_for_file: unused_field, await_only_futures

import 'dart:math';
import 'package:absensi_usr/app_log.dart';
import 'package:absensi_usr/staff.dart';
import 'package:absensi_usr/login.dart';
import 'package:absensi_usr/mail.dart';
import 'package:absensi_usr/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResetPassPage extends StatefulWidget {
  @override
  _ResetPassPageState createState() => _ResetPassPageState();
}

class _ResetPassPageState extends State<ResetPassPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nipCont = new TextEditingController();
  TextEditingController passCont = new TextEditingController();
  String _playerId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.green,
        body: Builder(
          builder: (context) => Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: true,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: AssetImage('assets/images/logo.png'),
                      ),
                    ),
                    Text(
                      'PRESENSIA',
                      style: TextStyle(
                        fontSize: 30.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Absensi Pegawai & Dosen UIN Suska Riau',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.teal.shade100,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 150.0,
                      height: 20.0,
                      child: Divider(color: Colors.teal.shade100),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 25.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: nipCont,
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.person),
                                  labelText: 'Masukkan NIP/NIK',
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Harus diisi';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 16.0,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: new MaterialButton(
                                  child: Text(
                                    "RESET PASSWORD",
                                    style: TextStyle(
                                      fontFamily: 'SourceSansPro',
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      try {
// process data
                                        DocumentReference staffRef =
                                            await FirebaseFirestore.instance
                                                .collection('staff')
                                                .doc(nipCont.text);

                                        DocumentSnapshot staff =
                                            await staffRef.get();

                                        if (!staff.exists) {
                                          throw ('NIP/NIK yang anda masukkan salah');
                                        }

                                        Staff _staff =
                                            Staff.fromJson(staff.data());

                                        if (_staff?.tokenReset != null) {
                                          throw ('Token sudah pernah dikirim ke email ${_staff.email} sebelumnya, silahkan cek kotak masuk.');
                                        }

                                        Random randomNum = new Random();
                                        String tokenReset = randomNum
                                            .nextInt(999999)
                                            .toString()
                                            .padLeft(6, '0');
                                        staffRef.update(<String, dynamic>{
                                          'token_reset': tokenReset,
                                          'app_log': AppLog.jsonFormatted
                                        });

                                        bool isEmailSent =
                                            await sendMailResetPass(
                                                context,
                                                _staff.email,
                                                _staff.nama,
                                                tokenReset);

                                        if (isEmailSent) {
                                          alertAct(
                                              context: context,
                                              barrierDismissible: false,
                                              content: Text(
                                                  'Token berhasil dikirim ke email ${_staff.email}, silahkan cek kotak masuk.'),
                                              actions: [
                                                TextButton(
                                                  child:
                                                      Text('KEMBALI KE LOGIN'),
                                                  onPressed: () => Navigator.of(
                                                          context)
                                                      .pushReplacement(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  LoginPage())),
                                                )
                                              ]);
                                        } else {
                                          print('email not sent');
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                duration:
                                                    const Duration(seconds: 3),
                                                content: Text(e.toString())));
                                      }
                                    }
                                  },
                                  elevation: 4.0,
                                  minWidth: double.infinity,
                                  height: 48.0,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    'Kembali ke Halaman Login',
                                    style: TextStyle(color: Colors.blue),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
