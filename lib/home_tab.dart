import 'package:absensi_usr/pengajuan_all.dart';
import 'package:absensi_usr/home.dart';
import 'package:absensi_usr/presence.dart';
import 'package:absensi_usr/setting.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String idStaff;

  HomePage({@required this.idStaff});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  List<String> _listTitles = ['Absensi', 'Utama', 'Status', 'Pengaturan'];
  List<Widget> _listTabs = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    _listTabs = [
      PresencePage(),
      HomeTab(),
      PengajuanAllPage(idStaff: widget.idStaff),
      SettingTab()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_listTitles[_selectedIndex]),
      ),
      body: _listTabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.fact_check_outlined), label: 'Absensi'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Utama'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Status'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.lightGreen,
        onTap: _onItemTapped,
      ),
    );
  }
}
