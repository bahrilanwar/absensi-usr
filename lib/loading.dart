// ignore_for_file: must_be_immutable

import 'package:absensi_usr/sys_config.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class LoadingWidget extends StatelessWidget {
  final String message;
  Widget btnAction;

  LoadingWidget({@required this.message, this.btnAction});

  Tween _animationTween = Tween<double>(begin: 0, end: pi * 10);

  @override
  Widget build(BuildContext context) {
    return Center(
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            Text('$appLegalese',
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    fontStyle: FontStyle.italic)),
            SizedBox(height: 16),
            Text('$message', textAlign: TextAlign.justify),
            SizedBox(height: 16),
            if (btnAction != null) btnAction
          ],
        ),
      ),
    );
  }
}
