import 'package:absensi_usr/login.dart';
import 'package:absensi_usr/permission.dart';
import 'package:absensi_usr/ubah_profil.dart';
import 'package:absensi_usr/session.dart';
import 'package:absensi_usr/sys_config.dart';
import 'package:absensi_usr/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sliding_switch/sliding_switch.dart';
import 'package:absensi_usr/waktu_kerja.dart';

import 'ubah_password.dart';

class SettingTab extends StatefulWidget {
  @override
  _SettingTabState createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  Future<SharedPreferences> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs;
    } catch (e) {
      return e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadSession(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          SharedPreferences session = snapshot.data;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: ListTile.divideTiles(context: context, tiles: [
                        ListTile(
                          leading: Icon(Icons.sync),
                          title: Text('Sinkronkan Profil'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            DocumentSnapshot staffUpdated =
                                await FirebaseFirestore.instance
                                    .collection('staff')
                                    .doc(prefs.getString(NO_INDUK))
                                    .get();
                            clearSession();
                            createSession(staffUpdated.data());
                            alert(context: context, children: [
                              Text('Sinkronisasi Profil Selesai')
                            ]);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Ubah Biodata'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () => showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return UbahProfil(prefs: session);
                              }).then((value) => _loadSession()),
                        ),
                        // ListTile(
                        //   leading: Icon(Icons.vpn_key),
                        //   title: Text('Fingerprint Login'),
                        //   onTap: () {},
                        //   trailing: SlidingSwitch(
                        //     value: false,
                        //     width: 100,
                        //     height: 30,
                        //     onChanged: (bool value) {
                        //       if(value==true){
                        //         showDialog(
                        //             barrierDismissible: false,
                        //             context: context,
                        //             builder: (BuildContext context) {
                        //               return UbahPassword(prefs: session);
                        //             }).then((value) => _loadSession());
                        //       }
                        //       print(value);
                        //     },
                        //     animationDuration: const Duration(milliseconds: 400),
                        //     onTap: () {},
                        //     onDoubleTap: () {},
                        //     onSwipe: () {},
                        //     colorOn: const Color(0xff6682c0),
                        //     colorOff: const Color(0xffdc6c73),
                        //     background: const Color(0xffe4e5eb),
                        //     buttonColor: const Color(0xfff7f5f7),
                        //     inactiveColor: const Color(0xff636f7b),
                        //   ),
                        // ),
                        ListTile(
                          leading: Icon(Icons.vpn_key),
                          title: Text('Ubah Password'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () => showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return UbahPassword(prefs: session);
                              }).then((value) => _loadSession()),
                        ),
                        ListTile(
                          leading: Icon(Icons.perm_identity),
                          title: Text('Perizinan Aplikasi'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      PermissionPage())),
                        ),
                        ListTile(
                            leading: Icon(Icons.lock_clock),
                            title: Text('Jam Kerja'),
                            trailing: Icon(Icons.chevron_right),
                            onTap: () => showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                      title: Text('Jam Kerja'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text('TUTUP'))
                                      ],
                                      content: Table(
                                          border: TableBorder.all(),
                                          children: SysConfig.listJamKerja(null)
                                              .map((jamKerja) =>
                                                  TableRow(children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(dayName(
                                                          jamKerja.weekday)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                          DateFormat('HH:mm')
                                                              .format(jamKerja
                                                                  .jamMasuk)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                          DateFormat('HH:mm')
                                                              .format(jamKerja
                                                                  .jamPulang)),
                                                    ),
                                                  ]))
                                              .toList()));
                                })),
                        // ListTile(
                        //   leading: Icon(Icons.menu_book_outlined,
                        //       color: Colors.black12),
                        //   title: Text(
                        //     'Panduan Aplikasi',
                        //     style: TextStyle(color: Colors.black12),
                        //   ),
                        //   trailing: Icon(
                        //     Icons.chevron_right,
                        //     color: Colors.black12,
                        //   ),
                        // ),
                        ListTile(
                          onTap: () async => callC3(context),
                          leading: Icon(Icons.help),
                          title: Text(
                            'Pusat Bantuan (C3)',
                          ),
                          trailing: Icon(Icons.chevron_right),
                        ),
                        ListTile(
                          onTap: () => showAboutDialog(
                              context: context,
                              applicationName: appName,
                              applicationVersion: getAppVer(),
                              applicationIcon:
                                  Image.asset(appIconPath, width: 100),
                              applicationLegalese: appLegalese),
                          leading: Icon(Icons.developer_mode),
                          title: Text('Tentang Aplikasi'),
                          trailing: Icon(Icons.chevron_right),
                        ),
                      ]).toList(),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '${appName.toUpperCase()} ${getAppVer()} $appLegalese',
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: MaterialButton(
                            color: Colors.pinkAccent,
                            onPressed: () async {
                              alertAct(
                                  context: context,
                                  content: Text(
                                      'Anda yakin ingin keluar dari Akun ini? Untuk masuk kembali menggunakan NIP/NIK dan password'),
                                  actions: [
                                    TextButton(
                                        onPressed: () async {
                                          await clearSession();
                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          LoginPage()));
                                        },
                                        child: Text('YA, SAYA INGIN KELUAR')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text('TIDAK'))
                                  ]);
                            },
                            child: Text('KELUAR (LOGOUT)',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          )),
                    )
                  ],
                ),
              ),
            ),
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
