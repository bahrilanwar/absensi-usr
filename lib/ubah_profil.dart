// ignore_for_file: unused_field, missing_return, unused_element, await_only_futures

import 'dart:io';

import 'package:absensi_usr/app_log.dart';
import 'package:absensi_usr/staff.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:absensi_usr/session.dart';
import 'package:absensi_usr/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UbahProfil extends StatefulWidget {
  final SharedPreferences prefs;

  UbahProfil({@required this.prefs});

  @override
  _UbahProfilState createState() => _UbahProfilState();
}

class _UbahProfilState extends State<UbahProfil> {
  final _formKey = GlobalKey<FormState>();
  Staff staff;
  bool _isSuccess = false;
  DocumentReference reference;

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
      TextInputType type, String label, TextEditingController controller,
      {readonly: false}) {
    ThemeData theme = Theme.of(context);
    return TextFormField(
      style: (readonly) ? TextStyle(color: theme.disabledColor) : null,
      readOnly: readonly,
      obscureText: (type == TextInputType.visiblePassword) ? true : false,
      keyboardType: type,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (controller.text.isEmpty) {
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
      {bool isRequired: true, bool readOnly: false}) {
    return FutureBuilder(
      future: parseJsonFromAssets(assetPath),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // return Text("Error : ${snapshot.error}");
          return Text("Terjadi kesalahan saat memuat $label");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LinearProgressIndicator();
        }

        List<String> data = snapshot.data;
        // print(snapshot.data);
        print('dropdown $label, controller.value : ${controller.text}');
        return (controller.text != null)
            ? DropdownButtonFormField(
                decoration: InputDecoration(labelText: label),
                value: controller.text,
                validator: (value) {
                  if (isRequired) {
                    if (value == null) {
                      return "$label wajib dipilih";
                    }
                    return null;
                  }
                },
                items: data.map((value) {
                  String nama = (value.isNotEmpty) ? value : 'Tidak Ada';
                  return DropdownMenuItem(child: Text(nama), value: value);
                }).toList(),
                disabledHint: Text(controller.text),
                onChanged: (readOnly)
                    ? null
                    : (value) {
                        controller.text = value;
                      },
              )
            : DropdownButtonFormField(
                decoration: InputDecoration(labelText: label),
                validator: (value) {
                  if (isRequired) {
                    if (value == null) {
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
  void initState() {
    reference = FirebaseFirestore.instance
        .collection('staff')
        .doc(widget.prefs.getString(NO_INDUK));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot> _streamStaff = reference.snapshots();

    return AlertDialog(
      title: Text('Ubah Biodata'),
      content: StreamBuilder<DocumentSnapshot>(
        stream: _streamStaff,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          print('no induk : ${widget.prefs.getString(NO_INDUK)}');
          print('datanya ada : ${snapshot.data.exists}');

          if (snapshot.data.exists) {
            staff = Staff.fromJson(snapshot.data.data());
            noIndukCont.text = staff.noInduk;
            namaCont.text = staff.nama;
            emailCont.text = staff.email;
            hpCont.text = staff.hp;
            unitKerjaCont.text = staff.unitKerja;
            jabatanStrukCont.text = staff.jabatanStruktural;
            jabatanFungCont.text = staff.jabatanFungsional;
            gradeCont.text = staff.grade;
            jenisPegawaiCont.text = staff.jenisPegawai;
            jenisTenagaCont.text = staff.jenisTenaga;

            if (staff.pangkatGolongan != null) {
              print('staff.pangkatGolongan != null : ${staff.pangkatGolongan}');
              pangkatGolCont.text = staff.pangkatGolongan;
            } else {
              print('staff.pangkatGolongan == null');
            }
          }

          return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                        radius: 50,
                        backgroundImage: (widget.prefs.getString(AVATAR_PATH) !=
                                    null &&
                                widget.prefs.getString(AVATAR_PATH).isNotEmpty)
                            ? NetworkImage(widget.prefs.getString(AVATAR_PATH))
                            : AssetImage('assets/images/dummy-ava.png')),
                    TextButton.icon(
                        onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Pilih foto dari'),
                                content: Row(
                                  children: <Widget>[
                                    ElevatedButton.icon(
                                        onPressed: () async {
                                          chooseImage(ImageSource.camera);
                                        },
                                        icon: Icon(Icons.camera),
                                        label: Text("Kamera")),
                                    SizedBox(width: 10),
                                    ElevatedButton.icon(
                                        onPressed: () async {
                                          chooseImage(ImageSource.gallery);
                                        },
                                        icon: Icon(Icons.filter),
                                        label: Text("Galeri")),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('BATAL')),
                                ],
                              );
                            }),
                        icon: Icon(Icons.camera, color: Colors.blue),
                        label: Text(
                          'Ganti Foto',
                          style: TextStyle(color: Colors.blue),
                        )),
                    Text(
                      '*Jika ingin mengubah data identitas silahkan hubungi Operator di unit ${unitKerjaCont.text}',
                      style:
                          TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                    SizedBox(height: 10),
                    _textField(TextInputType.number, 'NIP/NIK', noIndukCont,
                        readonly: true),
                    _textField(TextInputType.name, 'Nama Lengkap', namaCont,
                        readonly: true),
                    _textField(TextInputType.emailAddress, 'Email', emailCont,
                        readonly: true),
                    _textField(TextInputType.phone, 'Nomor HP', hpCont,
                        readonly: true),
                    _dropDownField('PNS/Non PNS',
                        'assets/master/jenis_pegawai.json', jenisPegawaiCont,
                        readOnly: true),
                    _dropDownField('Jenis Tenaga',
                        'assets/master/jenis_tenaga.json', jenisTenagaCont,
                        readOnly: true),
                    _dropDownField('Unit Kerja',
                        'assets/master/unit_kerja.json', unitKerjaCont,
                        readOnly: true),
                    _dropDownField(
                        'Jabatan Struktural',
                        'assets/master/jabatan_struktural.json',
                        jabatanStrukCont,
                        readOnly: true),
                    _dropDownField(
                        'Jabatan Fungsional',
                        'assets/master/jabatan_fungsional.json',
                        jabatanFungCont,
                        readOnly: true),
                    _dropDownField('Pangkat Golongan',
                        'assets/master/pangkat_golongan.json', pangkatGolCont,
                        readOnly: true),
                    _dropDownField(
                        'Grade', 'assets/master/grade.json', gradeCont,
                        readOnly: true),
                  ],
                ),
              ));
        },
      ),
      actions: [
        // StreamBuilder<DocumentSnapshot>(
        //     stream: _streamStaff,
        //     builder: (context, snapshot) {
        //       _isSuccess = snapshot.hasData && snapshot.data.exists;
        //       return ElevatedButton(
        //           color: Colors.pinkAccent,
        //           onPressed: (_isSuccess) ? () => _submit(reference) : null,
        //           child: Text(_isSuccess ? 'SIMPAN' : 'MEMUAT...'));
        //     }),
        TextButton(
            onPressed: () => Navigator.of(context).pop(), child: Text('BATAL'))
      ],
    );
  }

  void _submit(DocumentReference reference) async {
    if (_formKey.currentState.validate()) {
      try {
        reference.update(<String, dynamic>{
          'email': emailCont.text,
          'hp': hpCont.text,
          'jabatan_struktural': jabatanStrukCont.text,
          'jabatan_fungsional': jabatanFungCont.text,
          'pangkat_golongan': pangkatGolCont.text,
          'nama': namaCont.text,
          'no_induk': noIndukCont.text,
          'time_update': FieldValue.serverTimestamp(),
          'unit_kerja': unitKerjaCont.text,
          'jabatan': FieldValue.delete(), // TODO: Delete soon
          'grade': gradeCont.text,
          'jenis_pegawai': jenisPegawaiCont.text,
          'app_log': AppLog.jsonFormatted
        });

        DocumentSnapshot staffUpdated = await reference.get();
        clearSession();
        createSession(staffUpdated.data());
        Navigator.of(context).pop();
        alert(
            context: context,
            title: 'Berhasil',
            children: [Text('Biodata berhasil diperbarui')]);
      } catch (e) {
        alert(
            context: context,
            title: 'Kesalahan',
            children: [Text(e.toString(), style: TextStyle(fontSize: 18))]);
      }
    }
  }

  void chooseImage(ImageSource source) async {
    final prefs = await SharedPreferences.getInstance();
    // Widget body = LinearProgressIndicator();
    final picker = ImagePicker();

    var file = await picker.pickImage(
        source: source, maxWidth: 720, maxHeight: 720, imageQuality: 50);

    if (file != null) {
      try {
        File _file = File(file.path);
        int fileLength = await _file.length();

        double fileLengthKb = fileLength.toDouble() / 1000;
        print('file size : $fileLengthKb KB');

        if (fileLengthKb > 500) {
          throw ('Ukuran foto yang anda pilih terlalu besar');
        }

        String curDate =
            DateFormat('yyyy_MM_dd-HH_mm_ss').format(DateTime.now());
        print('curDate = $curDate');

        // delete old photo, if exist
        if (prefs.getString(AVATAR_PATH) != null &&
            prefs.getString(AVATAR_PATH).isNotEmpty) {
          firebase_storage.FirebaseStorage.instance
              .refFromURL(prefs.getString(AVATAR_PATH))
              .delete();
          print('${prefs.getString(AVATAR_PATH)} berhasil dihapus');
        }

        UploadTask uploadTask = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('avatar')
            .child('${prefs.getString(NO_INDUK)}-$curDate.jpg')
            .putFile(_file);

        String fullPath = await uploadTask.snapshot.ref.fullPath;
        uploadTask.whenComplete(() async {
          String downloadURL = await firebase_storage.FirebaseStorage.instance
              .ref(fullPath)
              .getDownloadURL();

          print('your downloadUrl : $downloadURL');

          // update field avatar on staff
          reference.update(<String, dynamic>{
            'avatar_path': downloadURL,
            'app_log': AppLog.jsonFormatted
          });

          DocumentSnapshot staffUpdated = await reference.get();
          clearSession();
          createSession(staffUpdated.data());
          Navigator.of(context).pop();
          alert(
              context: context,
              title: 'Berhasil',
              children: [Text('Foto profil berhasil diperbarui')]);
        });
      } on firebase_core.FirebaseException catch (e) {
        alert(context: context, children: [Text('Error when uploading file')]);
        print(e);
      }
    } else {
      print('file is null');
    }
  }
}
