// ignore_for_file: missing_return

import 'dart:convert';

import 'package:absensi_usr/home_tab.dart';
import 'package:absensi_usr/session.dart';
import 'package:absensi_usr/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class FormRegistrasi extends StatefulWidget {
  @override
  _FormRegistrasiState createState() => _FormRegistrasiState();
}

class _FormRegistrasiState extends State<FormRegistrasi> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController noIndukCont = TextEditingController();
  TextEditingController namaCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController hpCont = TextEditingController();
  TextEditingController passCont = TextEditingController();
  TextEditingController passCont2 = TextEditingController();
  TextEditingController unitKerjaCont = TextEditingController();
  TextEditingController jabatanStrukCont = TextEditingController();
  TextEditingController jabatanFungCont = TextEditingController();
  TextEditingController pangkatGolCont = TextEditingController();
  TextEditingController gradeCont = TextEditingController();
  TextEditingController jenisPegawaiCont = TextEditingController();
  TextEditingController jenisTenagaCont = TextEditingController();

  Widget _textField(
      TextInputType type, String label, TextEditingController controller) {
    return TextFormField(
      obscureText: (type == TextInputType.visiblePassword) ? true : false,
      keyboardType: type,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (controller.text.isEmpty) {
          print('textfield $label == $value');
          return "$label wajib diisi";
        }

        if (type == TextInputType.visiblePassword &&
            controller.text.length < 5) {
          return "Minimal 5 karakter";
        }

        if (type == TextInputType.emailAddress) {
          Pattern pattern =
              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
          RegExp regex = new RegExp(pattern);
          return (!regex.hasMatch(controller.text))
              ? "Email tidak valid"
              : null;
        }

        if (type == TextInputType.visiblePassword &&
            controller == passCont2 &&
            controller.text != passCont.text) {
          return "Kombinasi password tidak cocok";
        }
        return null;
      },
      controller: controller,
    );
  }

  Widget _dropDownField(
      String label, String assetPath, TextEditingController controller,
      {bool isRequired = true}) {
    return FutureBuilder(
      future: parseJsonFromAssets(assetPath),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error : ${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LinearProgressIndicator();
        }

        List<String> data = snapshot.data;
        print(snapshot.data);
        return DropdownButtonFormField(
          decoration: InputDecoration(labelText: label),
          validator: (value) {
            if (isRequired) {
              if (value == null) {
                print('dropdown $label == $value');
                return "$label wajib dipilih";
              }
              return null;
            }
          },
          items: data.map((value) {
            String nama = (value.isNotEmpty) ? value : 'Tidak Ada';
            return DropdownMenuItem(child: Text(nama), value: value);
          }).toList(),
          onChanged: (value) {
            controller.text = value;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
          children: [
            _textField(TextInputType.name, 'Nama Lengkap', namaCont),
            // TextFormField(
            //   keyboardType: TextInputType.name,
            //   decoration: InputDecoration(labelText: 'Nama Lengkap'),
            //   validator: (value) {
            //     if (value.isEmpty) {
            //       print('textfield nama lengkap == $value');
            //       return "Nama Lengkap wajib diisi";
            //     }
            //     return null;
            //   },
            //   controller: namaCont,
            // ),
            _textField(TextInputType.emailAddress, 'Email', emailCont),
            _textField(TextInputType.phone, 'Nomor HP', hpCont),
            _dropDownField('PNS/Non PNS', 'assets/master/jenis_pegawai.json',
                jenisPegawaiCont),
            _dropDownField(
                'Unit Kerja', 'assets/master/unit_kerja.json', unitKerjaCont),
            _dropDownField('Jabatan Struktural',
                'assets/master/jabatan_struktural.json', jabatanStrukCont),
            _dropDownField('Jabatan Fungsional',
                'assets/master/jabatan_fungsional.json', jabatanFungCont),
            _dropDownField('Pangkat Golongan',
                'assets/master/pangkat_golongan.json', pangkatGolCont),
            _dropDownField('Grade', 'assets/master/grade.json', gradeCont),
            _dropDownField('Jenis Tenaga', 'assets/master/jenis_tenaga.json',
                jenisTenagaCont),
            SizedBox(height: 40),
            _textField(TextInputType.number, 'NIP/NIK', noIndukCont),
            _textField(TextInputType.visiblePassword, 'Password', passCont),
            _textField(TextInputType.visiblePassword, 'Password Konfirmasi',
                passCont2),
            SizedBox(height: 20),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      try {
                        CollectionReference staffs =
                            FirebaseFirestore.instance.collection('staff');
                        // find if exist
                        DocumentReference documentReference =
                            staffs.doc(noIndukCont.text);
                        DocumentSnapshot staffExist =
                            await documentReference.get();

                        if (staffExist.exists) {
                          throw ('Nomor induk ${documentReference.id} sudah digunakan');
                        }

                        documentReference.set(<String, dynamic>{
                          'email': emailCont.text,
                          'hp': hpCont.text,
                          'is_aktif': true,
                          'jabatan_struktural': jabatanStrukCont.text,
                          'jabatan_fungsional': jabatanFungCont.text,
                          'pangkat_golongan': pangkatGolCont.text,
                          'nama': namaCont.text,
                          'no_induk': noIndukCont.text,
                          'time_create': FieldValue.serverTimestamp(),
                          'unit_kerja': unitKerjaCont.text,
                          'grade': gradeCont.text,
                          'jenis_pegawai': jenisPegawaiCont.text,
                          'jenis_tenaga': jenisTenagaCont.text,
                          'password': sha1
                              .convert(utf8.encode(passCont.text))
                              .toString(),
                        });

                        DocumentSnapshot staffAdded =
                            await documentReference.get();
                        if (!staffAdded.exists) {
                          throw ('Gagal registrasi');
                        }

                        createSession(staffAdded.data());
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => HomePage(
                                  idStaff: noIndukCont.text,
                                )));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())));
                      }
                    }
                  },
                  child: Text('REGISTRASI', style: TextStyle(fontSize: 16)),
                ))
          ],
        ));
  }
}
