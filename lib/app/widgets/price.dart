import 'dart:async';

import 'package:flutter/material.dart';

class RunningTimeWidget extends StatefulWidget {
  final DateTime entryTime;

  const RunningTimeWidget({Key? key, required this.entryTime})
      : super(key: key);

  @override
  _RunningTimeWidgetState createState() => _RunningTimeWidgetState();
}

class _RunningTimeWidgetState extends State<RunningTimeWidget> {
  late Stopwatch _stopwatch;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Duration runningDuration =
        _stopwatch.elapsed + DateTime.now().difference(widget.entryTime);

    int hours = runningDuration.inHours;
    int minutes = (runningDuration.inMinutes % 60);
    int seconds = (runningDuration.inSeconds % 60);

    return Text(
      '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      style: TextStyle(fontSize: 20),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
