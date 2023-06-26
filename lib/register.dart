import 'package:flutter/material.dart';
import 'package:absensi_usr/sys_config.dart';
import 'dart:math';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Tween _animationTween = Tween<double>(begin: 0, end: pi * 10);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrasi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: _animationTween,
                  duration: Duration(seconds: 60),
                  builder: (context, double value, child) {
                    return Transform.rotate(
                      angle: value,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: AssetImage('assets/images/logo.png'),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                Text('${appName.toUpperCase()} ${getAppVer()}',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                Text('$appLegalese',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        fontStyle: FontStyle.italic)),
                SizedBox(height: 16),
                Text(
                  '*Mohon maaf, saat ini proses Registrasi hanya bisa dilakukan oleh Administrator, silahkan hubungi C3 melalui WhatsApp $helpdeskPhone',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.justify,
                )
              ],
            ),
          ),
        ),
        // Form registrasi sementara disable
        // FormRegistrasi(),
      ),
    );
  }
}
