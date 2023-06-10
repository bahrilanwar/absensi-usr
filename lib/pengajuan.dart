import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum PengajuanStatus { TERKIRIM, DIVERIFIKASI, DITERIMA, DITOLAK }

class Pengajuan {
  final List<String> dokPendukung;
  final String jenis, staffId, status;
  final Timestamp mulaiTanggal, sampaiTanggal, timeCreate;
  final List<Log> log;

  Pengajuan(
      {@required this.dokPendukung,
      @required this.jenis,
      @required this.staffId,
      @required this.status,
      @required this.mulaiTanggal,
      @required this.sampaiTanggal,
      @required this.timeCreate,
      @required this.log});

  factory Pengajuan.fromJson(Map<String, dynamic> json) {
    return Pengajuan(
        dokPendukung:
            (json.containsKey('dok_pendukung') && json['dok_pendukung'] != null)
                ? List<String>.from(json['dok_pendukung'])
                : null,
        jenis: json['jenis'],
        staffId: json['staff_id'],
        status: json['status'],
        timeCreate: json['time_create'],
        mulaiTanggal: json['mulai_tanggal'],
        sampaiTanggal: json['sampai_tanggal'],
        log: (json['log'] != null)
            ? (json['log'] as List).map((data) => Log.fromJson(data)).toList()
            : null);
  }
}

class Log {
  final String deskripsi, staffId, status, komentar;
  final Timestamp time;

  Log(
      {@required this.deskripsi,
      @required this.staffId,
      this.status,
      this.time,
      this.komentar});

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
        deskripsi: json['deskripsi'],
        staffId: json['staff_id'],
        time: json['time'],
        status: json['status'],
        komentar: json['komentar']);
  }
}
