// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:absensi_usr/pengajuan.dart';
import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';
import 'package:absensi_usr/presensi.dart';

const kTileHeight = 50.0;

const completeColor = Color(0xff5e6172);
const inProgressColor = Color(0xff5ec792);
const todoColor = Color(0xffd1d2d7);
const rejectColor = Colors.red;

// saat ini widget khusus utk pengajuan dl cuti dan sakit
class ProcessTimelinePage extends StatefulWidget {
  ProcessTimelinePage({@required this.pengajuan});
  Pengajuan pengajuan;

  @override
  _ProcessTimelinePageState createState() => _ProcessTimelinePageState();
}

class _ProcessTimelinePageState extends State<ProcessTimelinePage> {
  int _processIndex;

  List<String> _processes = [
    'Terkirim',
    'Verifikasi',
    'Diterima',
  ];

  List<Icon> _processesIcon = [
    Icon(Icons.send),
    Icon(Icons.sync),
    Icon(Icons.check_circle_outline),
  ];

  Color getColor(int index) {
    if (index == _processIndex) {
      return inProgressColor;
    } else if (index < _processIndex) {
      return completeColor;
    } else if (index == _processes.length + 2) {
      return rejectColor;
    } else {
      return todoColor;
    }
  }

  @override
  void initState() {
    if (widget.pengajuan.log.length >= 1) {
      _processes[0] = 'Terkirim \n${widget.pengajuan.log[0].time.dateShort}';
      _processIndex = 1;
    }

    if (widget.pengajuan.log.length >= 2) {
      _processes[1] = 'Verifikasi \n${widget.pengajuan.log[1].time.dateShort}';
      _processIndex = 2;
    }

    if (widget.pengajuan.log.length >= 3 &&
        widget.pengajuan.status == 'terima') {
      _processes[2] = 'Diterima \n${widget.pengajuan.log[2].time.dateShort}';
      _processIndex = 3;
    }

    if (widget.pengajuan.log.length >= 3 &&
        widget.pengajuan.status == 'tolak') {
      _processes[2] = 'Ditolak \n${widget.pengajuan.log[2].time.dateShort}';
      _processIndex = 4;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Timeline.tileBuilder(
      theme: TimelineThemeData(
        direction: Axis.horizontal,
        connectorTheme: ConnectorThemeData(
          space: 30.0,
          thickness: 5.0,
        ),
      ),
      builder: TimelineTileBuilder.connected(
        connectionDirection: ConnectionDirection.before,
        itemExtentBuilder: (_, __) =>
            MediaQuery.of(context).size.width / _processes.length,
        oppositeContentsBuilder: (context, index) {
          /*
          uncomment for enable icon
          */
          return Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: _processesIcon[index],
          );
        },
        contentsBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _processes[index],
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: getColor(index),
              ),
            ),
          );
        },
        indicatorBuilder: (_, index) {
          var color;
          var child;
          if (index == _processIndex) {
            color = inProgressColor;
            child = Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            );
          } else if (index < _processIndex) {
            color = completeColor;
            child = Icon(
              Icons.check,
              color: Colors.white,
              size: 15.0,
            );
          } else {
            color = todoColor;
          }

          if (index <= _processIndex) {
            return Stack(
              children: [
                CustomPaint(
                  size: Size(30.0, 30.0),
                  painter: _BezierPainter(
                    color: color,
                    drawStart: index > 0,
                    drawEnd: index < _processIndex,
                  ),
                ),
                DotIndicator(
                  size: 30.0,
                  color: color,
                  child: child,
                ),
              ],
            );
          } else {
            return Stack(
              children: [
                CustomPaint(
                  size: Size(15.0, 15.0),
                  painter: _BezierPainter(
                    color: color,
                    drawEnd: index < _processes.length - 1,
                  ),
                ),
                OutlinedDotIndicator(
                  borderWidth: 4.0,
                  color: color,
                ),
              ],
            );
          }
        },
        connectorBuilder: (_, index, type) {
          if (index > 0) {
            if (index == _processIndex) {
              final prevColor = getColor(index - 1);
              final color = getColor(index);
              var gradientColors;
              if (type == ConnectorType.start) {
                gradientColors = [Color.lerp(prevColor, color, 0.5), color];
              } else {
                gradientColors = [prevColor, Color.lerp(prevColor, color, 0.5)];
              }
              return DecoratedLineConnector(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                  ),
                ),
              );
            } else {
              return SolidLineConnector(
                color: getColor(index),
              );
            }
          } else {
            return null;
          }
        },
        itemCount: _processes.length,
      ),
    );
  }
}

/// hardcoded bezier painter
/// TODO: Bezier curve into package component
class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    @required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    var angle;
    var offset1;
    var offset2;

    var path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius,
            radius) // TODO connector start & gradient
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius,
            radius) // TODO connector end & gradient
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}
