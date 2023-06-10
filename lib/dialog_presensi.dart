// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:absensi_usr/app_log.dart';
import 'package:absensi_usr/pengajuan.dart';
import 'package:absensi_usr/pengajuan_list.dart';
import 'package:absensi_usr/presensi_list.dart';
import 'package:absensi_usr/unit_kerja.dart';
import 'package:absensi_usr/form.dart';
import 'package:absensi_usr/device_info.dart';
import 'package:absensi_usr/session.dart';
import 'package:absensi_usr/sys_config.dart';
import 'package:absensi_usr/util.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_location/trust_location.dart';
import 'package:absensi_usr/app_config.dart';

import 'presensi.dart';

enum StatusKerja { absen_masuk, wfh, dinas_luar, sakit, cuti }

class DialogPresensi extends StatefulWidget {
  final SharedPreferences prefs;
  final BuildContext homeContext;

  DialogPresensi({@required this.prefs, @required this.homeContext});

  @override
  State createState() => new DialogPresensiState();
}

class DialogPresensiState extends State<DialogPresensi> {
  StatusKerja _status = StatusKerja.absen_masuk;
  String title = 'Absensi', btKirimTitle = 'MEMUAT LOKASI...';
  GeoPoint _myGeoPoint;
  bool _isMockLocation, _isShowJenis = true, _isLembur = false;
  Presensi _presensi;
  Future<Presensi> _futurePresensi;
  Map<String, dynamic> _myDeviceInfo;
  TextEditingController ketCont = TextEditingController();
  AppConfig app_config;

  Completer<GoogleMapController> _controller = Completer();

  static CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(0.466167, 101.355833),
    zoom: 14.4746,
  );

  Set<Polygon> _polygons = HashSet<Polygon>();
  List<LatLng> polyUinPanam = [
    LatLng(0.4695019046832535, 101.35020124497815),
    LatLng(0.4676908659060981, 101.35086954292682),
    LatLng(0.4643820317225554, 101.35302077539127),
    LatLng(0.4648701459389669, 101.35529907274105),
    LatLng(0.45924434867676456, 101.35759428880124),
    LatLng(0.45998646269701143, 101.35912869568953),
    LatLng(0.46462700357410125, 101.35701348027278),
    LatLng(0.4667054514592496, 101.36027165996886),
    LatLng(0.470774018744386, 101.36089689809886),
    LatLng(0.468206499984877, 101.35231981426398),
    LatLng(0.4696002220440307, 101.35158880056251)
  ];

  List<LatLng> polyUinSuka = [
    LatLng(0.5093577375472302, 101.43580175067905),
    LatLng(0.5109628040974086, 101.43581781215802),
    LatLng(0.5110186785971151, 101.43694461624584),
    LatLng(0.511339748268511, 101.43796502069908),
    LatLng(0.5101904776091586, 101.43831437095402),
  ];

  TextEditingController dateTxtContFrom = TextEditingController();
  TextEditingController dateTxtContTo = TextEditingController();
  dateTimeRangePicker() async {
    DateTimeRange picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: DateTimeRange(
        end: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day + 3),
        start: DateTime.now(),
      ),
    );
    setState(() {
      dateTxtContFrom.text =
          "${picked.start.year}-${picked.start.month}-${picked.start.day}";
      dateTxtContTo.text =
          "${picked.end.year}-${picked.end.month}-${picked.end.day}";
    });
  }

  List<File> files = [];
  Widget _dropDownJenisCuti;

  @override
  void initState() {
    super.initState();
    initApp();

    _dropDownJenisCuti = dropDownField(
        'Jenis Cuti', 'assets/master/jenis_cuti.json', ketCont,
        icon: Icon(Icons.note), isRequired: (_status == StatusKerja.cuti));

    _polygons.add(Polygon(
      polygonId: PolygonId('1'),
      points: polyUinPanam,
      strokeWidth: 2,
      strokeColor: Colors.red,
      fillColor: Colors.red.withOpacity(0.15),
    ));

    _polygons.add(Polygon(
      polygonId: PolygonId('2'),
      points: polyUinSuka,
      strokeWidth: 2,
      strokeColor: Colors.blue,
      fillColor: Colors.blue.withOpacity(0.15),
    ));
  }

  Future<void> initApp() async {
    Location location = new Location();
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.granted) {
      bool isGpsEnable = await location.serviceEnabled();
      if (isGpsEnable) {
        _futurePresensi = getTodayPresence(widget.prefs.getString(NO_INDUK),
            isCekoutNull: true);
        Presensi presensi = await _futurePresensi;
        print(presensi);
        setState(() {
          _presensi = presensi;
          if (_presensi != null && _presensi.checkIn != null) {
            _isShowJenis = false;
            _isLembur = _presensi.isLembur;
            title = 'Absensi Pulang';
            btKirimTitle = 'PULANG';
          } else {
            _isShowJenis = true;
            title = 'Absensi Masuk';
            btKirimTitle = 'MASUK';
          }
        });

        // jika platform Android
        if (Platform.isAndroid) {
          TrustLocation.start(5);
          getLocation(isFirstTime: true);
        } else if (Platform.isIOS) {
          getLocationIos(isFirstTime: true);
        } else {
          alert(context: context, children: [
            Text(
                'Platform yang anda gunakan : ${Platform.operatingSystem} tidak support plugin location')
          ]);
        }
      } else {
        setState(() {
          title = 'Gagal, GPS Tidak Aktif';
        });
        if (Theme.of(context).platform == TargetPlatform.android) {
          alert(context: context, title: 'Perhatian', children: [
            Text('Mohon aktifkan GPS karna absensi membutuhkan akses GPS anda',
                style: TextStyle(fontSize: 18)),
            ElevatedButton(
                onPressed: () {
                  final AndroidIntent intent = AndroidIntent(
                      action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                  intent.launch();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('AKTIFKAN'))
          ]);
        } else {
          alert(context: context, title: 'Perhatian', children: [
            Text('Mohon aktifkan GPS karna absensi membutuhkan akses GPS anda',
                style: TextStyle(fontSize: 18))
          ]);
        }
      }
    } else {
      setState(() {
        title = 'Berikan Izin Lokasi (GPS)';
      });
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == PermissionStatus.deniedForever) {
        alert(context: context, title: 'Perhatian', children: [
          Text('Mohon izinkan akses GPS untuk keperluan absensi',
              style: TextStyle(fontSize: 18)),
          ElevatedButton(
              onPressed: () {
                if (Theme.of(context).platform == TargetPlatform.android) {
                  final AndroidIntent intent = AndroidIntent(
                      action: 'android.settings.PRIVACY_SETTINGS');
                  intent.launch();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
              child: Text('BUKA PENGATURAN'))
        ]);
      }
    }

    _myDeviceInfo = await getDeviceInfo();
  }

  /// get location method, use a try/catch PlatformException.
  Future<void> getLocation({isFirstTime: false}) async {
    try {
      setState(() {
        btKirimTitle = 'MEMUAT LOKASI...';
      });
      TrustLocation.onChange.listen((values) async {
        if (this.mounted) {
          setState(() {
            if (values.latitude != null)
              _myGeoPoint = new GeoPoint(double.parse(values.latitude),
                  double.parse(values.longitude));

            _isMockLocation = values.isMockLocation;

            if (_presensi != null && _presensi.checkIn != null) {
              btKirimTitle = 'PULANG';
            } else {
              btKirimTitle = 'MASUK';
            }

            print(
                'isMockLocation : $_isMockLocation, lat : ${_myGeoPoint.latitude}, lng : ${_myGeoPoint.longitude}');
          });
          if (isFirstTime) {
            // change map camera to user location
            _kGooglePlex = CameraPosition(
              target: LatLng(_myGeoPoint.latitude, _myGeoPoint.longitude),
              zoom: 17.4746,
            );
            final GoogleMapController controller = await _controller.future;
            controller
                .animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
            setState(() {
              isFirstTime = false;
            });
          }
        } else {
          print('This is not mounted anymore');
          TrustLocation.stop();

          print('Trust location has been stopped');
        }
      });
    } on PlatformException catch (e) {
      print('PlatformException $e');
      alert(
          context: context,
          title: 'Kesalahan',
          children: [Text(e.toString(), style: TextStyle(fontSize: 18))]);
    }
  }

  Future<void> getLocationIos({isFirstTime: false}) async {
    try {
      setState(() {
        btKirimTitle = 'MEMUAT LOKASI...';
      });

      Location location = new Location();

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      location.onLocationChanged.listen((LocationData currentLocation) async {
        // Use current location
        if (this.mounted) {
          setState(() {
            _myGeoPoint = new GeoPoint(
                currentLocation.latitude, currentLocation.longitude);

            _isMockLocation = false;

            if (_presensi != null && _presensi.checkIn != null) {
              btKirimTitle = 'PULANG';
            } else {
              btKirimTitle = 'MASUK';
            }

            print(
                'isMockLocation : $_isMockLocation, lat : ${_myGeoPoint.latitude}, lng : ${_myGeoPoint.longitude}');
          });
        }
        if (isFirstTime) {
          // change map camera to user location
          _kGooglePlex = CameraPosition(
            target: LatLng(_myGeoPoint.latitude, _myGeoPoint.longitude),
            zoom: 17.4746,
          );
          final GoogleMapController controller = await _controller.future;
          controller
              .animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
          setState(() {
            isFirstTime = false;
          });
        }
      });
    } on PlatformException catch (e) {
      print('PlatformException $e');
      alert(
          context: context,
          title: 'Kesalahan',
          children: [Text(e.toString(), style: TextStyle(fontSize: 18))]);
    }
  }

  Future<dynamic> _getDateTimeNow() async {
    DateTime now = await NTP.now();

    if (now == null) {
      throw ('NTP.now() == null');
    }
    return now;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Builder(
          builder: (contextScaffold) => FutureBuilder(
              future: _futurePresensi,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  // Presensi presensi = snapshot.data;
                  return Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: GoogleMap(
                          myLocationEnabled: true,
                          mapType: MapType.terrain,
                          initialCameraPosition: _kGooglePlex,
                          polygons: _polygons,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Visibility(
                                visible: _isShowJenis,
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      'PILIH STATUS',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Row(
                                      children: [
                                        renderRadio(StatusKerja.absen_masuk,
                                            'Absen\nMasuk'),
                                        FutureBuilder<AppConfig>(
                                            future: getAppConfig(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasError) {
                                                return Text(
                                                    '${snapshot.error}');
                                              } else if (snapshot.hasData) {
                                                app_config = snapshot.data;
                                                return (app_config.wfhStatus)
                                                    ? renderRadio(
                                                        StatusKerja.wfh,
                                                        'WFH\n(Rumah)')
                                                    : Text('');
                                              }
                                              return CircularProgressIndicator();
                                            }),
                                        renderRadio(StatusKerja.dinas_luar,
                                            'Dinas Luar'),
                                      ],
                                    ),
                                    Row(children: [
                                      renderRadio(StatusKerja.sakit, 'Sakit'),
                                      renderRadio(StatusKerja.cuti, 'Cuti'),
                                      if (widget.prefs
                                          .getString(JABATAN_STRUKTURAL)
                                          .isEmpty)
                                        Expanded(child: Text(''))
                                    ]),
                                  ],
                                )),
                            SizedBox(height: 10),
                            // if (_status == StatusKerja.wfh &&
                            //     myUnitKerja != null &&
                            //     myUnitKerja.isLockdownNow())
                            //   Padding(
                            //     padding:
                            //         const EdgeInsets.symmetric(horizontal: 8.0),
                            //     child: Text(
                            //         '${myUnitKerja.nama} Lockdown mulai ${dateIndoShort(DateFormat.yMMMMEEEEd().format(myUnitKerja.startLockDown))} hingga ${dateIndoShort(DateFormat.yMMMMEEEEd().format(myUnitKerja.endLockDown))}',
                            //         style:
                            //             TextStyle(fontStyle: FontStyle.italic)),
                            //   ),
                            Visibility(
                              visible: (_status == StatusKerja.sakit ||
                                  _status == StatusKerja.dinas_luar ||
                                  _status == StatusKerja.cuti),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(children: [
                                  Text('PILIH DURASI TANGGAL',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  Row(
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
                                          onTap: () => dateTimeRangePicker(),
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
                                          onTap: () => dateTimeRangePicker(),
                                        ),
                                      )
                                    ],
                                  ),
                                  Visibility(
                                      visible:
                                          _status == StatusKerja.dinas_luar,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                            labelText: 'Keterangan',
                                            icon: Icon(Icons.note)),
                                        controller: ketCont,
                                        validator: (val) {
                                          if (_status ==
                                                  StatusKerja.dinas_luar &&
                                              ketCont.text.isEmpty) {
                                            return "Wajib diisi";
                                          }
                                          return null;
                                        },
                                      )),
                                  Visibility(
                                      visible: _status == StatusKerja.cuti,
                                      child: _dropDownJenisCuti),
                                  SizedBox(height: 20),
                                  Text(
                                      'LAMPIRKAN FOTO DOKUMEN PENDUKUNG (MINIMAL 1)',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(height: 10),
                                  Row(children: [
                                    Card(
                                        child: TextButton.icon(
                                            label: Text('Pilih Foto'),
                                            icon: Icon(Icons.photo),
                                            onPressed: () {
                                              pilihFoto(contextScaffold);
                                            })),
                                  ]),
                                  GridView.builder(
                                    itemCount: files.length,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    primary: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Card(
                                          child: Image.file(files[index]));
                                    },
                                  )
                                ]),
                              ),
                            ),
                            Visibility(
                                visible: (_status == StatusKerja.absen_masuk),
                                child: FutureBuilder(
                                    future: _getDateTimeNow(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Text('${snapshot.error}');
                                      } else if (snapshot.hasData) {
                                        DateTime now = snapshot.data;
                                        // jika hari ini bukan hari kerja, ceklis lembur otomatis aktif dan tidak bisa diubah
                                        bool isWorkingDay = now.isWorkingDay();

                                        _isLembur =
                                            (isWorkingDay) ? _isLembur : true;
                                        print('isWorkingDay : $isWorkingDay');
                                        print('_isLembur : $_isLembur');
                                        return CheckboxListTile(
                                            title: Text('Lembur'),
                                            subtitle:
                                                Text('Ceklis jika lembur'),
                                            value: _isLembur,
                                            onChanged: (val) {
                                              setState(() {
                                                _isLembur = val;
                                                print('_isLembur = $_isLembur');
                                              });
                                            });
                                      }

                                      return Center(
                                          child: CircularProgressIndicator());
                                    })),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return LinearProgressIndicator();
              })),
      bottomNavigationBar: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: MaterialButton(
                    color: Colors.pinkAccent,
                    onPressed: (_myGeoPoint != null)
                        ? () => _submit(widget.homeContext, _myGeoPoint)
                        : null,
                    child: Text(btKirimTitle,
                        style: TextStyle(
                            color: (_myGeoPoint != null
                                ? Colors.white
                                : Colors.grey)))),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('BATAL')),
              )
            ],
          ),
        ),
      ),
    );
  }

  void pilihFoto(BuildContext contextScaffold) {
    try {
      if (files.length >= 4) {
        throw ('Tidak bisa menambahkan foto lagi, maksimal 4');
      }

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Pilih foto dari'),
              content: Row(
                children: <Widget>[
                  ElevatedButton.icon(
                      onPressed: () async {
                        chooseImage(ImageSource.camera, contextScaffold);
                      },
                      icon: Icon(Icons.camera),
                      label: Text("Kamera")),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                      onPressed: () async {
                        chooseImage(ImageSource.gallery, contextScaffold);
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
          });
    } catch (e) {
      alert(context: context, children: [Text(e)]);
    }
  }

  void chooseImage(ImageSource source, BuildContext contextScaffold) async {
    try {
      XFile pickedFile = await ImagePicker().pickImage(
          source: source, maxWidth: 720, maxHeight: 720, imageQuality: 50);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        int _fileOriLengthInt = imageFile.lengthSync();
        double _fileOriSize = _fileOriLengthInt.toDouble() / 1000;
        print('_fileOriZize : $_fileOriSize KB');
        setState(() {
          files.add(imageFile);
        });
      }
      ScaffoldMessenger.of(contextScaffold).showSnackBar(SnackBar(
        content: Text('Berhasil memilih foto'),
        duration: Duration(seconds: 2),
      ));
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
      alert(context: context, children: [Text('$e')]);
    }
  }

  bool isWfHO(StatusKerja statusKerja) {
    if (statusKerja == StatusKerja.wfh ||
        statusKerja == StatusKerja.absen_masuk) {
      return true;
    }
    return false;
  }

  // component untuk render Radio
  Widget renderRadio(StatusKerja statusKerja, String label) {
    return Expanded(
        child: Row(
      children: [
        Radio(
            value: statusKerja,
            groupValue: _status,
            onChanged: (val) {
              setState(() {
                _status = val;
              });
            }),
        GestureDetector(
          onTap: () {
            setState(() {
              _status = statusKerja;
              ketCont.text = '';
            });
          },
          child: Text(
            '$label',
            style: TextStyle(fontSize: 14),
          ),
        )
      ],
    ));
  }

/*   fungsi untuk submit presensi (cekin/cekout), 
  fungsi ini hanya bisa dijalankan jika lokasi uer sudah didapatkan
  dan data presensi saat ini */
  void _submit(BuildContext _context, GeoPoint _myGeoPoint) async {
    print('Your lat : ${_myGeoPoint.latitude}, lng : ${_myGeoPoint.longitude}');

    try {
      // check internet connection
      Dio dio = new Dio();
      await dio.get('https://google.com');

      // jika mock location tendang,
      if (_isMockLocation) {
        throw new Exception(
            'Absensi tidak dapat dilakukan karna terdeteksi menggunakan fake gps (aplikasi tuyul)');
      }

      // validasi form jika DL, Sakit dan Cuti
      if (!isWfHO(_status)) {
        // jika belum mengisi durasi tanggal
        if (dateTxtContFrom.text.isEmpty || dateTxtContTo.text.isEmpty) {
          throw ('Durasi tanggal tidak boleh kosong');
        }

        if (_status == StatusKerja.dinas_luar && ketCont.text.isEmpty) {
          throw ('Keterangan dinas luar tidak boleh kosong');
        }

        if (_status == StatusKerja.cuti && ketCont.text.isEmpty) {
          throw ('Jenis cuti wajib dipilih');
        }

        if (files.length == 0) {
          throw ('Anda belum melampirkan foto dokumen pendukung');
        }

        // untuk menampung alamat gambar yang sudah berhasil diupload
        List<String> filesPath = [];

        // insert to firestore, collection pengajuan
        // insert ke collection pengajuan
        CollectionReference collection =
            FirebaseFirestore.instance.collection('pengajuan');
        DocumentReference reference = collection.doc(
            '${dateTxtContFrom.text}\_${dateTxtContTo.text}\_${widget.prefs.getString(NO_INDUK)}');
        DocumentSnapshot pengajuanAdded = await reference.get();
        Pengajuan p = (pengajuanAdded.data() != null)
            ? Pengajuan.fromJson(pengajuanAdded.data())
            : null;
        if (p != null &&
            (p.status == 'terima' ||
                p.status == 'terkirim' ||
                p.status == 'verifikasi')) {
          throw ('Anda sudah pernah mengajukan sebelumnya');
        }

        String status;
        switch (_status) {
          case StatusKerja.absen_masuk:
            status = 'wfo';
            break;

          case StatusKerja.wfh:
            status = 'wfh';
            break;

          case StatusKerja.dinas_luar:
            status = 'dinas luar';
            break;

          case StatusKerja.sakit:
            status = 'sakit';
            break;

          case StatusKerja.cuti:
            status = 'cuti';
            break;
        }

        DateTime dateFrom =
            DateFormat("yyyy-MM-dd").parse(dateTxtContFrom.text);
        DateTime dateTo = DateFormat("yyyy-MM-dd").parse(dateTxtContTo.text);

        final prefs = await SharedPreferences.getInstance();
        DateTime now = await NTP.now();
        if (now == null) {
          throw ('NTP.now() == null');
        }
        print('mau insert, ada filesPath.length : ${filesPath.length}');
        reference.set(<String, dynamic>{
          'check_in': <String, dynamic>{
            'is_mock_location': _isMockLocation,
            'location': _myGeoPoint,
            'waktu': FieldValue.serverTimestamp(),
            'device_info': _myDeviceInfo,
          },
          'dok_pendukung': filesPath,
          'jenis': status,
          'log': [
            <String, dynamic>{
              'deskripsi':
                  'Dikirim oleh ${prefs.getString(NAMA)} (${widget.prefs.getString(NO_INDUK)})',
              'staff_id': widget.prefs.getString(NO_INDUK),
              'status': 'terkirim',
              'time': Timestamp.fromDate(now)
            }
          ],
          'mulai_tanggal': Timestamp.fromDate(dateFrom),
          'sampai_tanggal': Timestamp.fromDate(dateTo),
          'staff_id': widget.prefs.getString(NO_INDUK),
          'status': 'terkirim',
          'time_create': FieldValue.serverTimestamp(),
          'app_log': AppLog.jsonFormatted,
          'ket': ketCont.text
        });

        // upload foto to firebase storage
        files.asMap().forEach((index, value) async {
          UploadTask uploadTask = FirebaseStorage.instance
              .ref()
              .child('pengajuan')
              .child('${widget.prefs.getString(NO_INDUK)}')
              .child(
                  '${dateTxtContFrom.text}_${dateTxtContFrom.text}_$index.jpg')
              .putFile(files[index]);

          String fullPath = uploadTask.snapshot.ref.fullPath;
          uploadTask.whenComplete(() async {
            String downloadURL =
                await FirebaseStorage.instance.ref(fullPath).getDownloadURL();

            print('files index-$index downloadUrl : $downloadURL');

            // tampung downloadURL di list baru
            print('ada filesPath.length : ${filesPath.length}');
            filesPath.add(downloadURL);
            print('ada filesPath.length : ${filesPath.length}');
            if (filesPath.length == files.length) {
              reference.update(<String, dynamic>{
                'dok_pendukung': FieldValue.arrayUnion(filesPath),
                'app_log': AppLog.jsonFormatted
              });
            }
          });
        });

        ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 5),
            content: Text(
                'Permohonan ${status.toUpperCase()} berhasil dikirim, progress dapat dilihat pada menu Status.')));
      } else {
        DateTime now = await NTP.now();
        if (now == null) {
          throw ('NTP.now() == null');
        }
        // Jika WFH || WFO
        if (_presensi != null && _presensi.checkIn != null) {
          // staff sudah cekin

          final bool confirm = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Perhatihan'),
                  content: Text('Anda yakin ingin absen pulang?'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text('YA')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: Text('TIDAK'))
                  ],
                );
              });

          if (!confirm) return null;

          if (_presensi.jenis == 'wfo') {
            // jik wfo, cek apakah lokasi di kantor
            if (!checkIfValidMarker(
                    LatLng(_myGeoPoint.latitude, _myGeoPoint.longitude),
                    polyUinPanam) &&
                !checkIfValidMarker(
                    LatLng(_myGeoPoint.latitude, _myGeoPoint.longitude),
                    polyUinSuka))
              throw Exception(
                  'Tidak bisa absen karna anda berada diluar wilayah kantor');
          }

          // pastikan minimal sudah lebih 30 menit dari cekin
          if (now.isBefore(
              _presensi.checkIn.waktu.toDate().add(Duration(minutes: 30)))) {
            throw ('Absensi pulang hanya bisa dilakukan minimal 30 menit setelah absen masuk');
          }

          String strToday = DateFormat('yyyy-MM-dd').format(now);
          CollectionReference collection =
              FirebaseFirestore.instance.collection('presensi');
          DocumentReference reference =
              collection.doc('$strToday\_${widget.prefs.getString(NO_INDUK)}');
          DocumentSnapshot presensiAdded = await reference.get();
          if (!presensiAdded.exists) {
            throw ('Absensi dengan kode $strToday\_${widget.prefs.getString(NO_INDUK)} tidak ditemukan');
          }

          reference.update(<String, dynamic>{
            'check_out': <String, dynamic>{
              'device_info': _myDeviceInfo,
              'is_mock_location': _isMockLocation,
              'location': _myGeoPoint,
              'waktu': FieldValue.serverTimestamp()
            },
            'is_lembur': _isLembur,
            'time_update': FieldValue.serverTimestamp(),
            'app_log': AppLog.jsonFormatted
          });

          ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 5),
              content: Text('Anda berhasil absen pulang, terima kasih.')));
        } else {
          // staff belum cekin
          if (_status == StatusKerja.absen_masuk) {
            // jik wfo, cek apakah lokasi di kantor
            if (!checkIfValidMarker(
                    LatLng(_myGeoPoint.latitude, _myGeoPoint.longitude),
                    polyUinPanam) &&
                !checkIfValidMarker(
                    LatLng(_myGeoPoint.latitude, _myGeoPoint.longitude),
                    polyUinSuka))
              throw Exception(
                  'Tidak bisa absen karna anda berada diluar wilayah kantor');
          }

          // return null;

          String strToday = DateFormat('yyyy-MM-dd').format(now);
          CollectionReference collection =
              FirebaseFirestore.instance.collection('presensi');
          DocumentReference reference =
              collection.doc('$strToday\_${widget.prefs.getString(NO_INDUK)}');
          DocumentSnapshot presensiAdded = await reference.get();
          if (presensiAdded.exists) {
            throw ('Anda sudah absen masuk sebelumnya');
          }

          String status;
          switch (_status) {
            case StatusKerja.absen_masuk:
              status = 'wfo';
              break;

            case StatusKerja.wfh:
              status = 'wfh';
              break;

            case StatusKerja.dinas_luar:
              status = 'dinas luar';
              break;

            case StatusKerja.sakit:
              status = 'sakit';
              break;

            case StatusKerja.cuti:
              status = 'cuti';
              break;
          }

          reference.set(<String, dynamic>{
            'check_in': <String, dynamic>{
              'is_mock_location': _isMockLocation,
              'location': _myGeoPoint,
              'waktu': FieldValue.serverTimestamp(),
              'device_info': _myDeviceInfo,
            },
            'check_out': null,
            'is_lembur':
                (_status == StatusKerja.absen_masuk) ? _isLembur : false,
            'jenis': status,
            'ket': ketCont.text,
            'staff_id': widget.prefs.getString(NO_INDUK),
            'time_create': FieldValue.serverTimestamp(),
            'time_update': null,
            'app_log': AppLog.jsonFormatted
          });

          presensiAdded = await reference.get();
          if (!presensiAdded.exists) {
            throw ('Gagal absen masuk, coba lagi');
          }

          ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 5),
              content: Text('Anda berhasil absen masuk, selamat bekerja.')));
        }
      }

      Navigator.of(context).pop();
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              titlePadding: EdgeInsets.fromLTRB(12, 24.0, 24.0, 0.0),
              contentPadding: EdgeInsets.all(12),
              title: Text('Perhatian'),
              children: [
                Text(
                  (e is DioError)
                      ? 'Periksa koneksi internet anda lalu coba lagi'
                      : e.toString(),
                  style: TextStyle(fontSize: 18),
                )
              ],
            );
          });
    }
  }
}
