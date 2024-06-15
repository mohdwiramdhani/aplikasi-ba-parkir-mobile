import 'dart:async';

import 'package:flutter/material.dart';

class RunningTimeWidget extends StatefulWidget {
  final DateTime entryTime;

  RunningTimeWidget({required this.entryTime});

  @override
  _RunningTimeWidgetState createState() => _RunningTimeWidgetState();
}

class _RunningTimeWidgetState extends State<RunningTimeWidget> {
  late StreamController<Duration> _durationController;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _durationController = StreamController<Duration>();
    _currentTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      _currentTime = DateTime.now();
      Duration elapsedTime = _currentTime.difference(widget.entryTime);
      _durationController.add(elapsedTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: _durationController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Duration elapsed = snapshot.data!;
          int hours = elapsed.inHours;
          int minutes = (elapsed.inMinutes % 60);
          int seconds = (elapsed.inSeconds % 60);

          return Text(
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          );
        } else {
          return Container(); // Widget ini dapat diubah sesuai kebutuhan
        }
      },
    );
  }

  @override
  void dispose() {
    _durationController.close();
    super.dispose();
  }
}
