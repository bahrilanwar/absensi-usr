import 'package:cloud_firestore/cloud_firestore.dart';

class Staff {
  String noInduk,
      nama,
      password,
      unitKerja,
      email,
      hp,
      jabatanStruktural,
      jabatanFungsional,
      pangkatGolongan,
      tokenReset,
      grade,
      jenisPegawai,
      playerId,
      jenisTenaga;
  Timestamp timeCreate, timeUpdate;
  bool isAktif;

  Staff(
      {this.noInduk,
      this.nama,
      this.password,
      this.unitKerja,
      this.email,
      this.hp,
      this.jabatanStruktural,
      this.jabatanFungsional,
      this.pangkatGolongan,
      this.timeCreate,
      this.timeUpdate,
      this.isAktif,
      this.tokenReset,
      this.grade,
      this.jenisPegawai,
      this.playerId,
      this.jenisTenaga});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
        noInduk: json['no_induk'],
        nama: json['nama'],
        password: json['password'] ?? null,
        unitKerja: json['unit_kerja'],
        email: json['email'],
        hp: json['hp'],
        jabatanStruktural: json['jabatan_struktural'],
        jabatanFungsional: json['jabatan_fungsional'],
        pangkatGolongan: json['pangkat_golongan'],
        timeCreate: json['time_create'],
        timeUpdate: json['time_update'],
        isAktif: json['is_aktif'],
        tokenReset: (json['token_reset'] != null) ? json['token_reset'] : null,
        grade: json.containsKey('grade') ? json['grade'] : null,
        jenisPegawai: json['jenis_pegawai'],
        playerId: json['player_id'],
        jenisTenaga: json['jenis_tenaga']);
  }
}
