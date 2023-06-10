import 'package:absensi_usr/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';

import 'pengajuan_list.dart';

class PengajuanAllPage extends StatefulWidget {
  final String idStaff;

  PengajuanAllPage({@required this.idStaff});

  @override
  _PengajuanAllPageState createState() => _PengajuanAllPageState();
}

class _PengajuanAllPageState extends State<PengajuanAllPage> {
  DateTime now = new DateTime.now();
  TextEditingController dateTxtContFrom = TextEditingController();
  TextEditingController dateTxtContTo = TextEditingController();
  DateTime startDate, endDate;

  Future<Null> _selectDate(BuildContext context, bool isFrom) async {
    DateTime now = await NTP.now();
    if (now == null) {
      throw ('NTP.now() == null');
    }
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year, now.month, 1),
        // firstDate: DateTime(2020),
        lastDate: DateTime(now.year, now.month, 31));
    if (picked != null && picked != now) {
      setState(() {
        now = picked;
        if (isFrom) {
          dateTxtContFrom.text = formatDate(now);
          startDate = now;
          dateTxtContTo.text = dateTxtContFrom.text;
          endDate = now;
        } else {
          dateTxtContTo.text = formatDate(now);
          endDate = now;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        'dapatkan data pengajuan dengan staff_id isEqualTo ${widget.idStaff}');
    var pengajuan = FirebaseFirestore.instance
        .collection('pengajuan')
        .where('staff_id', isEqualTo: widget.idStaff);

    if (dateTxtContFrom.text != null && dateTxtContFrom.text.length > 0) {
      pengajuan = pengajuan
          .where('time_create',
              isGreaterThanOrEqualTo: DateTime.parse(dateTxtContFrom.text))
          .where('time_create',
              isLessThan: DateTime.parse(dateTxtContTo.text)
                  .add(new Duration(days: 1)));
    } else {
      DateTime now = DateTime.now();
      pengajuan = pengajuan
          .where('time_create',
              isGreaterThanOrEqualTo:
                  new DateTime(now.year, now.month, now.day))
          .where('time_create',
              isLessThan: new DateTime(now.year, now.month, now.day)
                  .add(new Duration(days: 1)));
    }

    pengajuan = pengajuan.orderBy('time_create');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.datetime,
                    controller: dateTxtContFrom,
                    readOnly: true,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.date_range),
                      labelText: 'Dari tanggal',
                      hintText: 'Cari',
                    ),
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                // SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.datetime,
                    controller: dateTxtContTo,
                    readOnly: true,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.date_range),
                      labelText: 'Hingga tanggal',
                      hintText: 'Cari',
                    ),
                    onTap: () => _selectDate(context, false),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(child: PengajuanList(query: pengajuan)),
        ],
      ),
    );
  }
}
