import 'package:absensi_usr/pengajuan_page.dart';
import 'package:absensi_usr/pengajuan_all.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeContentPage extends StatelessWidget {
  final String idStaff;

  HomeContentPage({@required this.idStaff});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: true,
      child: Expanded(
        child: GridView.count(
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          primary: false,
          crossAxisCount: 4,
          children: [
            // renderMenu(context, 'Dinas Luar', 'assets/svg/dinas_luar.svg',
            //     PengajuanPage(title: 'Pengajuan Dinas Luar')),
            // renderMenu(context, 'Izin', 'assets/svg/izin.svg',
            //     PengajuanPage(title: 'Pengajuan Izin')),
            // renderMenu(context, 'Cuti', 'assets/svg/cuti.svg',
            //     PengajuanPage(title: 'Pengajuan Izin')),
            // renderMenu(
            //     context,
            //     'Daftar Pengajuan',
            //     'assets/svg/daftar_pengajuan.svg',
            //     PengajuanAllPage(
            //       idStaff: idStaff,
            //     )),
            // Card(
            //   child: Column(
            //     children: [
            //       SvgPicture.network(
            //         'https://image.flaticon.com/icons/svg/1904/1904437.svg',
            //         height: 32,
            //       ),
            //       Text('Menu 4')
            //     ],
            //   ),
            // ),
            // Card(
            //   child: Column(
            //     children: [
            //       SvgPicture.network(
            //         'https://image.flaticon.com/icons/svg/1904/1904235.svg',
            //         height: 32,
            //       ),
            //       Text('Menu 5')
            //     ],
            //   ),
            // ),
            // Card(
            //   child: Column(
            //     children: [
            //       SvgPicture.network(
            //         'https://image.flaticon.com/icons/svg/1904/1904221.svg',
            //         height: 32,
            //       ),
            //       Text('Menu 6')
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget renderMenu(BuildContext context, String title, String svgURL,
      Widget destinationWidget) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => destinationWidget)),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgURL,
              height: 36,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),

    );
  }
}
