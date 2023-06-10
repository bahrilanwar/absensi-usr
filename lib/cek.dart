import 'package:cloud_firestore/cloud_firestore.dart';

class Cek {
  final Timestamp waktu;
  final bool isMockLocation;
  final GeoPoint location;

  Cek({this.waktu, this.isMockLocation, this.location});

  factory Cek.fromJson(Map<String, dynamic> json) {
    return Cek(
        isMockLocation: json['is_mock_location'],
        waktu: json['waktu'],
        location: json['location']);
  }
}
