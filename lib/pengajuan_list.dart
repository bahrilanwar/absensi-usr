// ignore_for_file: must_be_immutable, unused_local_variable

import 'package:absensi_usr/pengajuan.dart';
import 'package:absensi_usr/pengajuan_list.dart';
import 'package:absensi_usr/process_timeline.dart';
import 'package:absensi_usr/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:absensi_usr/presensi_list.dart';
import 'util.dart';
import 'package:absensi_usr/presensi.dart';

class PengajuanList extends StatelessWidget {
  Query query;
  PengajuanList({@required this.query});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Terjadi kesalahan : ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return (snapshot?.data?.docs?.length == 0)
              ? Center(child: Text('Tidak ada data'))
              : ListView(
                  shrinkWrap: true,
                  children: snapshot.data.docs.map((DocumentSnapshot document) {
                    Pengajuan pengajuan = Pengajuan.fromJson(document.data());
                    return renderRow(context, pengajuan);
                  }).toList(),
                );
        });
  }

  Widget renderRow(BuildContext context, Pengajuan pengajuan) {
    var date;
    return Card(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          new ListTile(
            leading: Text(
              '${pengajuan.status.toUpperCase()}',
              style: TextStyle(
                  fontSize: 14,
                  color: (pengajuan.status == 'ditolak'
                      ? Colors.red
                      : Colors.green)),
            ),
            isThreeLine: true,
            title: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('${pengajuan.jenis.toUpperCase()}'),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mulai'),
                      Text(': ${pengajuan.mulaiTanggal.date}')
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sampai'),
                      Text(': ${pengajuan.sampaiTanggal.date}')
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Diajukan'),
                      Text(': ${pengajuan.timeCreate.date}')
                    ],
                  ),
                  ButtonBar(
                    children: [
                      TextButton.icon(
                          label: Text('DOKUMEN'),
                          icon: Icon(Icons.filter),
                          onPressed: () {
                            alert(
                                context: context,
                                title: 'Foto Dokumen Pendukung',
                                children: pengajuan.dokPendukung
                                    .map((dokPendukung) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Image.network(dokPendukung),
                                        ))
                                    .toList());
                          })
                    ],
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Divider(thickness: 1.5, color: Colors.grey[200]),
          ),
          SizedBox(
              height: 110,
              child: ProcessTimelinePage(
                pengajuan: pengajuan,
              )),
        ],
      ),
    );
  }
}
