import 'package:absensi_usr/cek.dart';
import 'package:absensi_usr/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Presensi {
  final String staffId, jenis, ket;
  final Timestamp timeCreate, timeUpdate;
  final Cek checkIn, checkOut;
  final bool isLembur;

  String get waktuCekin {
    if (jenis == 'wfo' || jenis == 'wfh' || jenis == 'dinas luar') {
      return checkIn?.waktu?.time ?? 'Belum';
    }
    return '-';
  }

  String get waktuCekout {
    if (jenis == 'wfo' || jenis == 'wfh' || jenis == 'dinas luar') {
      return checkOut?.waktu?.time ?? 'Belum';
    }
    return '-';
  }

  Presensi(
      {@required this.staffId,
      @required this.jenis,
      @required this.ket,
      @required this.timeCreate,
      this.timeUpdate,
      @required this.checkIn,
      this.checkOut,
      this.isLembur});

  factory Presensi.fromJson(Map<String, dynamic> json) {
    return Presensi(
        staffId: json['staff_id'],
        jenis: json['jenis'],
        ket: (json.containsKey('ket')) ? json['ket'] : '',
        timeCreate: json['time_create'],
        timeUpdate: json['time_update'],
        checkIn:
            (json['check_in'] != null) ? Cek.fromJson(json['check_in']) : null,
        checkOut: (json['check_out'] != null)
            ? Cek.fromJson(json['check_out'])
            : null,
        isLembur: (json.containsKey('is_lembur')) ? json['is_lembur'] : false);
  }
}

// fungsi untuk mendapatkan data presensi hari ini by nomor induk
Future<Presensi> getTodayPresence(String noInduk,
    {bool isCekoutNull = false}) async {
  DateTime now = new DateTime.now();
  QuerySnapshot currPresensi;
  if (isCekoutNull) {
    currPresensi = await FirebaseFirestore.instance
        .collection('presensi')
        .where('staff_id', isEqualTo: noInduk)
        .where('check_in.waktu',
            isGreaterThanOrEqualTo: new DateTime(now.year, now.month, now.day))
        .where('check_in.waktu',
            isLessThan: new DateTime(now.year, now.month, now.day)
                .add(new Duration(days: 1)))
        .where('check_out', isEqualTo: null)
        .orderBy('check_in.waktu', descending: true)
        .limit(1)
        .get();
  } else {
    currPresensi = await FirebaseFirestore.instance
        .collection('presensi')
        .where('staff_id', isEqualTo: noInduk)
        .where('check_in.waktu',
            isGreaterThanOrEqualTo: new DateTime(now.year, now.month, now.day))
        .where('check_in.waktu',
            isLessThan: new DateTime(now.year, now.month, now.day)
                .add(new Duration(days: 1)))
        .orderBy('check_in.waktu', descending: true)
        .limit(1)
        .get();
  }
  Presensi presensi = (currPresensi.docs.length > 0)
      ? Presensi.fromJson(currPresensi.docs[0].data())
      : null;
  print("presensi : $presensi");
  return presensi;
}

Stream<QuerySnapshot> streamTodayPresence(String noInduk,
    {bool isCekoutNull = false}) {
  DateTime now = new DateTime.now();
  Stream<QuerySnapshot> currPresensi;
  if (isCekoutNull) {
    currPresensi = FirebaseFirestore.instance
        .collection('presensi')
        .where('staff_id', isEqualTo: noInduk)
        .where('check_in.waktu',
            isGreaterThanOrEqualTo: new DateTime(now.year, now.month, now.day))
        .where('check_in.waktu',
            isLessThan: new DateTime(now.year, now.month, now.day)
                .add(new Duration(days: 1)))
        .where('check_out', isEqualTo: null)
        .orderBy('check_in.waktu', descending: true)
        .limit(1)
        .snapshots();
  } else {
    currPresensi = FirebaseFirestore.instance
        .collection('presensi')
        .where('staff_id', isEqualTo: noInduk)
        .where('check_in.waktu',
            isGreaterThanOrEqualTo: new DateTime(now.year, now.month, now.day))
        .where('check_in.waktu',
            isLessThan: new DateTime(now.year, now.month, now.day)
                .add(new Duration(days: 1)))
        .orderBy('check_in.waktu', descending: true)
        .limit(1)
        .snapshots();
  }
  return currPresensi;
}

extension IntExt on int {
  String get format2Dig {
    return this.toString().padLeft(2, '0');
  }
}

extension TimestampExt on Timestamp {
  String get date {
    String date = DateFormat.yMMMMEEEEd().format(this.toDate());
    return dateIndo(date);
  }

  String get dateShort {
    String date = DateFormat.yMMMMEEEEd().format(this.toDate());
    return dateIndoShort(date);
  }

  String get time {
    return DateFormat.Hms().format(this.toDate());
  }
}

extension StringExt on String {
  String get removeSpace {
    return this.replaceAll(new RegExp(r"\s+"), "");
  }
}
