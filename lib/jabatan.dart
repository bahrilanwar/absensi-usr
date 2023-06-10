class Jabatan {
  final String idJabatan, nama;
  Jabatan({this.idJabatan, this.nama});

  factory Jabatan.fromJson(Map<String, dynamic> json){
    return Jabatan(
      idJabatan: json['id_jabatan'],
      nama: json['nama']
    );
  }
}