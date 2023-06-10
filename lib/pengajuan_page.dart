import 'package:absensi_usr/form.dart';
import 'package:flutter/material.dart';

enum Pengajuan { DINAS_LUAR, IZIN, CUTI }

class PengajuanPage extends StatefulWidget {
  @override
  _PengajuanPageState createState() => _PengajuanPageState();

  PengajuanPage({@required this.title});

  final String title;
}

class _PengajuanPageState extends State<PengajuanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormPengajuan(),
        ),
      ),
    );
  }
}
