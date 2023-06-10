// ignore_for_file: null_aware_before_operator

import 'package:absensi_usr/presensi_list.dart';
import 'package:absensi_usr/login.dart';
import 'package:absensi_usr/dialog_presensi.dart';
import 'package:absensi_usr/home_content.dart';
import 'package:absensi_usr/session.dart';
import 'package:absensi_usr/sys_config.dart';
import 'package:absensi_usr/util.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'presensi.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String noInduk = "Memuat...",
      nama = "Memuat...",
      currCekin = "Memuat...",
      currCekout = "Memuat...",
      currJenis = "",
      avatarPath;

  bool isFabVisible = false;

  SharedPreferences prefs;

  String currDate = dateIndo(DateFormat.yMMMMEEEEd().format(DateTime.now()));

  _loadSessionData() async {
    print('_loadSessionData()');
    try {
      prefs = await SharedPreferences.getInstance();
      bool isLogin = prefs.getBool(IS_LOGIN) ?? false;
      if (!isLogin) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
      }

      setState(() {
        nama = prefs.getString(NAMA);
        noInduk = prefs.getString(NO_INDUK);
        avatarPath = prefs.getString(AVATAR_PATH);
        currCekin = "Memuat...";
        currCekout = "Memuat...";
      });
    } catch (e) {
      alert(
          context: context,
          title: 'Kesalahan',
          children: [Text(e.toString(), style: TextStyle(fontSize: 18))]);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: StreamBuilder<QuerySnapshot>(
          stream: streamTodayPresence(noInduk),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              alert(context: context, children: [Text('${snapshot.error}')]);
              return null;
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            Presensi presensi = (snapshot?.data?.docs?.length > 0)
                ? Presensi.fromJson(snapshot?.data?.docs[0]?.data())
                : null;

            if (presensi?.checkOut != null) {
              isFabVisible = false;
            } else {
              isFabVisible = true;

              /*
          Uncomment dibawah jika hanya bisa absen senin-jumat
          */
              // DateTime now = DateTime.now();
              // if (now.weekday > 5) {
              //   // jika hari sabtu, minggu
              //   isFabVisible = false;
              // }

              // jika izin, fab checkout tidak muncul
              if (presensi?.jenis == 'izin') {
                isFabVisible = false;
              }
            }

            return Visibility(
              visible: isFabVisible,
              child: Builder(
                builder: (BuildContext scaffoldContext) => FloatingActionButton(
                  onPressed: () async {
                    Location location = new Location();
                    PermissionStatus _permissionGranted =
                        await location.hasPermission();
                    if (_permissionGranted != PermissionStatus.granted) {
                      _permissionGranted = await location.requestPermission();
                      if (_permissionGranted ==
                          PermissionStatus.deniedForever) {
                        alert(context: context, title: 'Perhatian', children: [
                          Text(
                              'Mohon izinkan akses GPS untuk keperluan absensi',
                              style: TextStyle(fontSize: 18)),
                          ElevatedButton(
                              onPressed: () {
                                if (Theme.of(context).platform ==
                                    TargetPlatform.android) {
                                  final AndroidIntent intent = AndroidIntent(
                                      data: "package:$appPackageName",
                                      action:
                                          'android.settings.APPLICATION_DETAILS_SETTINGS');
                                  intent.launch();
                                  Navigator.of(context).pop();
                                } else {
                                  alert(context: context, children: [
                                    Text('Request location permission')
                                  ]);
                                }
                              },
                              child: Text('BUKA PENGATURAN'))
                        ]);
                      }
                    } else {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => DialogPresensi(
                                  prefs: prefs, homeContext: scaffoldContext)))
                          .then((value) => _loadSessionData());
                      // showDialog(
                      //     barrierDismissible: false,
                      //     context: context,
                      //     builder: (BuildContext context) {
                      //       return DialogPresensi(
                      //           noInduk: noInduk, homeContext: scaffoldContext);
                      //     }).then((val) => _loadSessionData());
                    }
                  },
                  backgroundColor: Colors.pinkAccent,
                  child: Icon(Icons.fingerprint),
                ),
              ),
            );
          }),
      body: Stack(
        children: [
          Container(
            height: size.height,
            decoration: BoxDecoration(
                image: DecorationImage(
                    alignment: Alignment.topCenter,
                    image: AssetImage('assets/images/top_header.png'))),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    height: 64,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage:
                              (avatarPath != null && avatarPath.isNotEmpty)
                                  ? NetworkImage(avatarPath)
                                  : AssetImage('assets/images/dummy-ava.png'),
                        ),
                        SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nama.showMax(26),
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            Text(noInduk,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white))
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                          stream: streamTodayPresence(noInduk),
                          builder: (context, snapshot) {
                            Presensi presensi;
                            if (snapshot.hasError) {
                              return Text('${snapshot.error}');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            if (snapshot.data.docs.length == 0) {
                              currCekin = 'Belum';
                              currCekout = 'Belum';
                            } else {
                              presensi = (snapshot?.data?.docs?.length > 0)
                                  ? Presensi.fromJson(
                                      snapshot?.data?.docs[0]?.data())
                                  : null;
                              currCekin = presensi.waktuCekin;
                              currCekout = presensi.waktuCekout;
                              // print('currCekout : $currCekout');
                              currJenis = presensi?.jenis?.toUpperCase() ?? '';
                            }

                            return Card(
                              color: Colors.white,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                      leading: SizedBox(
                                        width: 50,
                                        child: Center(
                                            child: Text(currJenis,
                                                style: TextStyle(
                                                    color: Colors.green))),
                                      ),
                                      isThreeLine: true,
                                      trailing: SizedBox(
                                          width: 25,
                                          child: Center(
                                            child: Icon(Icons.timer_sharp),
                                          )),
                                      title: Text(currDate),
                                      subtitle: Text("Masuk : $currCekin"
                                          "\nPulang : $currCekout")),
                                ],
                              ),
                            );
                          })
                    ],
                  ),
                  SizedBox(height: 80),
                  SingleChildScrollView(
                    child: SizedBox(
                      child: Container(
                        constraints:
                            BoxConstraints(maxHeight: 400, minWidth: 100),
                        child: Column(
                          children: [
                            Card(
                              color: Colors.grey[100],
                              // margin: EdgeInsets.fromLTRB(100, 30, 100, 10),
                              // margin: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Text(
                                    'Jam Kerja',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        height: 2),
                                    textAlign: TextAlign.center,
                                  ),
                                  Table(
                                      border: TableBorder.symmetric(),
                                      children: SysConfig.listJamKerja(null)
                                          .map((jamKerja) =>
                                              TableRow(children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    '  ' +
                                                        dayName(
                                                            jamKerja.weekday),
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    DateFormat('HH:mm').format(
                                                        jamKerja.jamMasuk),
                                                    style: TextStyle(),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    DateFormat('HH:mm').format(
                                                        jamKerja.jamPulang),
                                                    style: TextStyle(),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ]))
                                          .toList()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  HomeContentPage(idStaff: noInduk),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
