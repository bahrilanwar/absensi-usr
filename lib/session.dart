import 'package:shared_preferences/shared_preferences.dart';

const String IS_LOGIN = "is_login";
const String NO_INDUK = "no_induk";
const String NAMA = "nama";
const String UNIT_KERJA = "unit_kerja";
const String EMAIL = "email";
const String HP = "hp";
const String JABATAN_STRUKTURAL = "jabatan_struktural";
const String JABATAN_FUNGSIONAL = "jabatan_fungsional";
const String PANGKAT_GOLONGAN = "pangkat_golongan";
const String AVATAR_PATH = "avatar_path";

Future createSession(Map<String, dynamic> staff) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(IS_LOGIN, true);
  prefs.setString(NO_INDUK, staff['no_induk']);
  prefs.setString(NAMA, staff['nama']);
  prefs.setString(UNIT_KERJA, staff['unit_kerja']);
  prefs.setString(EMAIL, staff['email']);
  prefs.setString(HP, staff['hp']);
  prefs.setString(JABATAN_STRUKTURAL, staff['jabatan_struktural']);
  prefs.setString(JABATAN_FUNGSIONAL, staff['jabatan_fungsional']);
  prefs.setString(PANGKAT_GOLONGAN, staff['pangkat_golongan']);
  prefs.setString(AVATAR_PATH, staff['avatar_path']);
  return true;
}

Future clearSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
  return true;
}

Future getIdStaff() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(NO_INDUK);
}
