import 'dart:async';
import 'package:flutter/material.dart';

class TimeAgoWidget extends StatefulWidget {
  final DateTime dateTime;
  final TextStyle? style;

  const TimeAgoWidget({super.key, required this.dateTime, this.style});

  @override
  State<TimeAgoWidget> createState() => _TimeAgoWidgetState();
}

class _TimeAgoWidgetState extends State<TimeAgoWidget> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 30) return "just now";
    if (diff.inMinutes < 1) return "${diff.inSeconds}s";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    if (diff.inDays == 1) return "yesterday";
    if (diff.inDays < 7) return "${diff.inDays}d";
    if (diff.inDays < 30) return "${(diff.inDays / 7).floor()}w";
    if (diff.inDays < 365) return "${(diff.inDays / 30).floor()}mo";

    return "${(diff.inDays / 365).floor()}y";
  }

  @override
  Widget build(BuildContext context) {
    return Text(timeAgo(widget.dateTime), style: widget.style);
  }
}
