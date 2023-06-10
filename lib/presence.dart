import 'package:absensi_usr/presensi_list.dart';
import 'package:absensi_usr/session.dart';
import 'package:absensi_usr/util.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';

class PresencePage extends StatefulWidget {
  @override
  _PresencePageState createState() => _PresencePageState();
}

class _PresencePageState extends State<PresencePage> {
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
        firstDate: DateTime(now.year, now.month - 1, 1),
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
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: size.width,
              child: Row(
                children: [
                  SizedBox(
                    width: size.width * 0.45,
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
                  SizedBox(
                    width: size.width * 0.45,
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
          ),
          SizedBox(height: 10),
          Expanded(
            flex: 6,
            child: FutureBuilder(
              future: getIdStaff(),
              builder: (context, snapshot) {
                print(snapshot.data);
                if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  return PresensiList(
                      idStaff: snapshot.data,
                      waktuFrom: dateTxtContFrom.text,
                      waktuTo: dateTxtContTo.text);
                }

                return CircularProgressIndicator();
              },
            ),
          )
        ],
      ),
    );
  }
}
