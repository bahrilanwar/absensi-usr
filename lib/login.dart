// ignore_for_file: unused_element

import 'dart:convert';

import 'package:absensi_usr/app_log.dart';
import 'package:absensi_usr/staff.dart';
import 'package:absensi_usr/home_tab.dart';
import 'package:absensi_usr/reset_pass.dart';
import 'package:absensi_usr/session.dart';
import 'package:absensi_usr/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'bubble_indication_painter.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nipCont = new TextEditingController();
  TextEditingController passCont = new TextEditingController();
  String _playerId;
  // Initially password is obscure
  bool _obscureText = true;
  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.green,
        body: Builder(
          builder: (context) => Center(
              child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: true,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                color: Colors.amber,
                                spreadRadius: 5)
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.amber,
                          child: CircleAvatar(
                            radius: 90,
                            backgroundImage:
                                AssetImage('assets/images/logo.png'),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'PRESENSIA',
                      style: TextStyle(
                        fontSize: 30.0,
                        color: Colors.amber,
                        overflow: TextOverflow.fade,
                        letterSpacing: 3,
                        height: 2.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Absensi Pegawai & Dosen UIN Suska Riau',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.teal.shade100,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 150.0,
                      height: 25.0,
                      child: Divider(
                        color: Color.fromARGB(255, 228, 175, 0),
                        thickness: 2,
                      ),
                    ),
                    Container(
                      width: 500,
                      constraints:
                          BoxConstraints(maxHeight: 500, minHeight: 200),
                      child: _buildFormLogin(),
                    ),
                    // _buildMenuBar(context),
                    // Expanded(
                    //   // flex: 1,
                    //   child: PageView(
                    //     controller: _pageController,
                    //     onPageChanged: (i) {
                    //       if (i == 0) {
                    //         setState(() {
                    //           right = Colors.white;
                    //           left = Colors.black;
                    //         });
                    //       } else if (i == 1) {
                    //         setState(() {
                    //           right = Colors.black;
                    //           left = Colors.white;
                    //         });
                    //       }
                    //     },
                    //     children: <Widget>[
                    //       Container(
                    //           height: 20,
                    //           child: new ConstrainedBox(
                    //             constraints: BoxConstraints(
                    //                 maxHeight: 25, maxWidth: 100),
                    //             child: _buildFormLogin(),
                    //           )),
                    //       new ConstrainedBox(
                    //         constraints: const BoxConstraints.expand(),
                    //         child: _buildFormBiometric(),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: TextButton(
                // splashColor: Colors.transparent,
//                 highlightColor: Colors.transparent,
                onPressed: _onSignInButtonPress,
                child: Text(
                  "Masuk",
                  style: TextStyle(
                      color: left,
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              ),
            ),
            //Container(height: 33.0, width: 1.0, color: Colors.white),
            Expanded(
              child: TextButton(
                // splashColor: Colors.transparent,
//                 highlightColor: Colors.transparent,
                onPressed: _onSignUpButtonPress,
                child: Text(
                  "Biometrik",
                  style: TextStyle(
                      color: right,
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  Widget _buildFormLogin() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      margin: EdgeInsets.only(top: 5, bottom: 100, left: 15, right: 15),
      child: Padding(
        padding: const EdgeInsets.all(19.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text(
                '*Jika belum memiliki Akun silahkan Registrasi terlebih dahulu',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 10),
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: passCont,
                      obscureText: _obscureText,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.lock),
                        labelText: 'Masukkan Password',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Harus diisi';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: new Icon(_obscureText
                          ? Icons.visibility
                          : Icons.visibility_off))
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              SizedBox(
                width: double.infinity,
                child: new MaterialButton(
                  child: Text(
                    "LOGIN",
                    style: TextStyle(
                      fontFamily: 'SourceSansPro',
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      actionLogin();
                    }
                  },
                  elevation: 4.0,
                  minWidth: double.infinity,
                  height: 48.0,
                  color: Colors.pinkAccent,
                ),
              ),
              SizedBox(height: 10),
              // TextButton(
              //     padding: EdgeInsets.all(0),
              //     onPressed: () => Navigator.push(context,
              //         MaterialPageRoute(builder: (context) => RegisterPage())),
              //     child: Text(
              //       "Belum punya akun? Registrasi di sini",
              //       style: TextStyle(color: Colors.blue),
              //     )),
              TextButton(
                  // padding: EdgeInsets.all(0),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ResetPassPage())),
                  child: Text(
                    'Lupa password? Reset di sini',
                    style: TextStyle(color: Colors.blue),
                  )),
              TextButton(
                  // padding: EdgeInsets.all(0),
                  onPressed: () async => callC3(context),
                  child: Text(
                    "Butuh bantuan? Hubungi C3",
                    style: TextStyle(color: Colors.blue),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormBiometric() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white,
      margin: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 25.0),
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.fingerprint, size: 150, color: Colors.pinkAccent),
            SizedBox(height: 20),
            Text('Login dengan Sidik Jari',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
            SizedBox(height: 8),
            Text('Gunakan sidik jari untuk login yang lebih cepat dan mudah',
                style: TextStyle(fontWeight: FontWeight.w300),
                textAlign: TextAlign.justify),
            SizedBox(height: 16.0),
            // SizedBox(
            //   width: double.infinity,
            //   child: new MaterialButton(
            //     child: Text(
            //       "GUNAKAN SIDIK JARI",
            //       style: TextStyle(
            //         fontFamily: 'SourceSansPro',
            //         color: Colors.white,
            //         fontSize: 16.0,
            //       ),
            //     ),
            //     onPressed: () {},
            //     elevation: 4.0,
            //     minWidth: double.infinity,
            //     height: 48.0,
            //     color: Colors.pinkAccent,
            //   ),
            // ),
          ])),
    );
  }

  void actionLogin() async {
    try {
// process data

      String passHash = sha1.convert(utf8.encode(passCont.text)).toString();
      DocumentReference staffRef =
          FirebaseFirestore.instance.collection('staff').doc(nipCont.text);

      DocumentSnapshot staff = await staffRef.get();

      if (!staff.exists) {
        throw ('NIP/NIK tidak ditemukan, silahkan cek kembali');
      }

      Staff _staff = Staff.fromJson(staff.data());

      if (!staff.exists || _staff?.tokenReset != null) {
        if (_staff.password != passHash && _staff.tokenReset != passCont.text) {
          throw ('NIP/NIK atau Password atau Token yang anda masukkan salah');
        }
      } else if (_staff.password != passHash) {
        throw ('NIP/NIK atau Password yang anda masukkan salah');
      }

      var status = await OneSignal.shared.getDeviceState();
      _playerId = status.userId;

      if (_staff.playerId != null && _staff.playerId.isNotEmpty) {
        // staff sudah pernah login dan perangkat dg yg sblmnya tdk sama
        if (_staff.playerId != _playerId) {
          throw Exception(
              'Tidak bisa login karna perangkat yang digunakan tidak sama dengan perangkat sebelumnya, silahkan hubungi Administrator melalui WhatsApp C3 jika anda mengganti perangkat');
        }
      } else {
        // TODO: Segera ganti rulesnya utk cek staff yang memiliki playerId sama dengan staff lain
        // jika playerId sudah digunakan
        QuerySnapshot playerIdSnap = await FirebaseFirestore.instance
            .collection('staff')
            .where('player_id', isEqualTo: _playerId)
            .get();

        Staff playerIdStaff =
            (playerIdSnap.docs != null && playerIdSnap.docs.length > 0)
                ? Staff.fromJson(playerIdSnap.docs.first.data())
                : null;
        if (playerIdStaff != null) {
          throw Exception(
              'Tidak bisa login karna perangkat yang anda gunakan terdaftar pada akun atas nama ${playerIdStaff.nama} (${playerIdStaff.noInduk})');
        }
      }

      // update playerId
      staffRef.update(<String, dynamic>{
        'player_id': _playerId,
        'token_reset': null,
        'app_log': AppLog.jsonFormatted
      });

      if (_staff?.tokenReset != null) {
        staffRef.update(<String, dynamic>{
          'password': sha1.convert(utf8.encode(_staff.tokenReset)).toString(),
        });
      }

      createSession(staff.data());
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomePage(idStaff: _staff.noInduk)));
    } catch (e) {
      // print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 5), content: Text(e.toString())));
    }
  }
}
