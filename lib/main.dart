import 'dart:io';
import 'package:absensi_usr/staff.dart';
import 'package:absensi_usr/app_config.dart';
import 'package:absensi_usr/login.dart';
import 'package:absensi_usr/session.dart';
import 'package:absensi_usr/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'loading.dart';

import 'home_tab.dart';
import 'sys_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Remove this method to stop OneSignal Debugging
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  OneSignal.shared.setAppId("a76b840d-e984-486c-bbbc-099bcb77f55f");

  OneSignal.shared.setNotificationWillShowInForegroundHandler(
      (OSNotificationReceivedEvent event) {
    /// Display Notification, send null to not display, send notification to display
    event.complete(event.notification);
  });

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  await OneSignal.shared
      .promptUserForPushNotificationPermission(fallbackToSettings: true);

  OneSignal.shared
      .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
    // will be called whenever a notification is opened/button pressed.
    print('notifiaction opened');
  });

  // set orientation portrait only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  // // create the initialization Future outside of `build`
  // final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences prefs;

  _loadSession(context) async {
    await Firebase.initializeApp();
    prefs = await SharedPreferences.getInstance();
    bool isLogin = prefs.getBool(IS_LOGIN) ?? false;

    if (isLogin) {
      DocumentReference staffRef = FirebaseFirestore.instance
          .collection('staff')
          .doc(prefs.getString(NO_INDUK));

      DocumentSnapshot staff = await staffRef.get();

      if (!staff.exists) {
        throw ('NIP/NIK tidak ditemukan, silahkan cek kembali');
      }

      Staff _staff = Staff.fromJson(staff.data());
      if (_staff.playerId == null) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()));
      }
    }

    return isLogin;
  }

  @override
  Widget build(BuildContext context) {
    print('build ui...');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: Scaffold(
        body: FutureBuilder(
          future: getAppConfig(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return LoadingWidget(message: '${snapshot.error}');
            } else if (snapshot.connectionState == ConnectionState.done) {
              AppConfig appConfig = snapshot.data;
              if (appConfig == null) {
                return LoadingWidget(
                    message: 'Periksa koneksi internet anda lalu coba lagi',
                    btnAction: MaterialButton(
                      color: Colors.pinkAccent,
                      onPressed: () => setState(() {}),
                      child: Text('REFRESH',
                          style: TextStyle(color: Colors.white)),
                    ));
              }
              print('aplikasi anda terbaru : ${appConfig.isAppNewest}');
              return (appConfig.isAppNewest)
                  ? _mainWidget(context)
                  : LoadingWidget(
                      message:
                          'Mohon maaf $appName yang anda gunakan (${getAppVer()}) bukan versi terbaru (${appConfig.appConfigVer}), silahkan unduh versi terbaru dibawah ini',
                      btnAction: MaterialButton(
                        color: Colors.pinkAccent,
                        onPressed: () => _launchURL(context, appConfig),
                        child: Text('UNDUH PRESENSIA DISINI',
                            style: TextStyle(color: Colors.white)),
                      ));
            }

            return LoadingWidget(
                message:
                    'Sedang mencocokkan versi aplikasi, harap menunggu...');
          },
        ),
      ),
    );
  }

  void _launchURL(BuildContext context, AppConfig appConfig) async {
    String _url;
    if (Platform.isAndroid) {
      _url = (appConfig.isPlayStoreReady)
          ? 'https://play.google.com/store/apps/details?id=id.ptipd_usr.absensi_usr2'
          : 'https://bit.ly/presensia-apk';
    } else if (Platform.isIOS) {
      _url = 'https://apps.apple.com/id/app/presensia/id1559689977';
    }
    await canLaunchUrlString(_url)
        ? await launchUrlString(_url)
        : alert(
            context: context,
            children: [SelectableText('Unduh melalui alamat : $_url')]);
  }

  Widget _mainWidget(BuildContext context) {
    return FutureBuilder(
      future: _loadSession(context),
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Scaffold(
              body: LoadingWidget(
                  message: 'Sedang memuat data aplikasi, harap menunggu...'),
            );
          case ConnectionState.done:
            if (snapshot.hasData) {
              return (snapshot.data)
                  ? HomePage(
                      idStaff: prefs.getString(NO_INDUK),
                    )
                  : LoginPage();
            } else {
              return Scaffold(
                  body: SafeArea(
                      child: Container(
                          child: Text('Error.. : ${snapshot.error}'))));
            }
            break;
          case ConnectionState.none:
            // TODO: Handle this case.
            break;
        }
      },
    );
  }
}
