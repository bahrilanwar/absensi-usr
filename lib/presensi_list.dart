// ignore_for_file: null_aware_in_logical_operator, null_aware_in_condition

import 'package:absensi_usr/app_log.dart';
import 'package:absensi_usr/presensi_list.dart';
import 'package:absensi_usr/sys_config.dart';
import 'package:absensi_usr/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'presensi.dart';

class PresensiList extends StatelessWidget {
  final String idStaff, waktuFrom, waktuTo;

  PresensiList({@required this.idStaff, this.waktuFrom, this.waktuTo});

  @override
  Widget build(BuildContext context) {
    var absensis = FirebaseFirestore.instance
        .collection('presensi')
        .where('staff_id', isEqualTo: idStaff);

    if (waktuFrom != null && waktuFrom.length > 0) {
      absensis = absensis
          .where('check_in.waktu',
              isGreaterThanOrEqualTo: DateTime.parse(waktuFrom))
          .where('check_in.waktu',
              isLessThan: DateTime.parse(waktuTo).add(new Duration(days: 1)));
    } else {
      DateTime now = DateTime.now();
      absensis = absensis
          .where('check_in.waktu',
              isGreaterThanOrEqualTo:
                  new DateTime(now.year, now.month, now.day))
          .where('check_in.waktu',
              isLessThan: new DateTime(now.year, now.month, now.day)
                  .add(new Duration(days: 1)));
    }

    absensis = absensis.orderBy('check_in.waktu');

    return StreamBuilder<QuerySnapshot>(
      stream: absensis.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Terjadi kesalahan : ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return (snapshot.data.docs.length == 0)
            ? Center(child: Text('Tidak ada data, pilih tanggal'))
            : ListView(
                children: snapshot.data.docs.map((DocumentSnapshot document) {
                  // dapatkan presensi dari docs
                  Presensi presensi = Presensi.fromJson(document.data());
                  // dapatkan master jam kerja berdasarkan input nama hari
                  MasterJamKerja masterJamKerja = getMasterJamkerja(
                      presensi.checkIn.waktu.toDate(), presensi);

                  Timestamp _checkIn = presensi?.checkIn?.waktu;
                  Timestamp _checkOut = presensi?.checkOut?.waktu;

                  String _durasiKerja = '-', _durasiLembur = '';

                  if (_checkOut != null) {
                    DateTime _checkInDt =
                        DateTime.parse(_checkIn?.toDate().toString());
                    DateTime _checkOutDt =
                        DateTime.parse(_checkOut?.toDate().toString());

                    int _selisihJam =
                        _checkOutDt.difference(_checkInDt).inHours;
                    int _selisihMenit =
                        _checkOutDt.difference(_checkInDt).inMinutes % 60;
                    _durasiKerja = "$_selisihJam Jam, $_selisihMenit Menit";
                  }

                  // jika lembur
                  if (presensi?.isLembur &&
                          presensi.checkOut != null &&
                          presensi.checkOut != null ??
                      false) {
                    // jika lembur di hari kerja
                    if (masterJamKerja != null) {
                      Duration selisihLembur = presensi?.checkOut?.waktu
                          ?.toDate()
                          ?.difference(masterJamKerja?.jamPulang);
                      _durasiLembur =
                          '${(selisihLembur.inHours % 24).format2Dig}:${(selisihLembur.inMinutes % 60).format2Dig}:${(selisihLembur.inSeconds % 60).format2Dig}';
                    } else {
                      // jika lmbur diluar hari kerja
                      Duration selisihLembur = presensi?.checkOut?.waktu
                          ?.toDate()
                          ?.difference(presensi?.checkIn?.waktu?.toDate());
                      _durasiLembur =
                          '${(selisihLembur.inHours % 24).format2Dig}:${(selisihLembur.inMinutes % 60).format2Dig}:${(selisihLembur.inSeconds % 60).format2Dig}';
                    }
                  }

                  return Card(
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        new ListTile(
                          leading: SizedBox(
                              width: 50,
                              child: Text(
                                '${presensi?.jenis?.toUpperCase()}',
                                style: TextStyle(color: Colors.green),
                              )),
                          isThreeLine: true,
                          trailing: GestureDetector(
                              child: Icon(Icons.info,
                                  color: (presensi?.ket?.isNotEmpty
                                      ? Colors.green
                                      : Colors.grey)),
                              onTap: (presensi?.ket?.isNotEmpty)
                                  ? () => alert(
                                          context: context,
                                          title:
                                              "${presensi.checkIn.waktu.date}",
                                          children: [
                                            Linkify(
                                                onOpen: (link) async {
                                                  if (await canLaunchUrlString(
                                                      link.url)) {
                                                    await launchUrlString(
                                                        link.url);
                                                  } else {
                                                    throw 'Could not launch $link';
                                                  }
                                                },
                                                text: presensi?.ket)
                                          ])
                                  : null),
                          title: Text(presensi.checkIn.waktu.date),
                          subtitle: RichText(
                              text: TextSpan(
                                  style: TextStyle(color: Colors.black45),
                                  children: [
                                TextSpan(
                                    text: "Masuk : ${presensi.waktuCekin}"),
                                TextSpan(
                                    text: "\nPulang : ${presensi.waktuCekout}"),
                                TextSpan(text: "\nDurasi  : $_durasiKerja"),
                              ])),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child:
                              Divider(thickness: 1.5, color: Colors.grey[200]),
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.spaceBetween,
                          buttonPadding: EdgeInsets.all(2),
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 18, bottom: 8),
                              child: Visibility(
                                  visible: presensi.isLembur,
                                  child: Text("\nLembur  : $_durasiLembur")),
                            ),
                            Visibility(
                              visible: presensi.jenis == 'wfo' &&
                                  presensi.checkOut != null,
                              child: TextButton.icon(
                                  icon: Checkbox(
                                      value: presensi.isLembur,
                                      onChanged: (val) {
                                        updateLembur(presensi, val, context);
                                      }),
                                  label: Text('LEMBUR'),
                                  onPressed: () {}),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
      },
    );
  }

  void updateLembur(
      Presensi presensi, bool newLembur, BuildContext context) async {
    String strDate =
        DateFormat('yyyy-MM-dd').format(presensi.checkIn.waktu.toDate());
    CollectionReference collection =
        FirebaseFirestore.instance.collection('presensi');
    DocumentReference reference =
        collection.doc('$strDate\_${presensi.staffId}');
    DocumentSnapshot presensiAdded = await reference.get();
    if (!presensiAdded.exists) {
      throw ('Absensi dengan kode $strDate\_${presensi.staffId} tidak ditemukan');
    }

    reference.update(<String, dynamic>{
      'is_lembur': newLembur,
      'time_update': FieldValue.serverTimestamp(),
      'app_log': AppLog.jsonFormatted
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 5),
        content: Text('Berhasil update')));
  }
}
