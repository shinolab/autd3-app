import 'package:flutter/material.dart';

import 'package:autd3/autd3.dart';
import '../../settings.dart';

class SilentPage extends StatefulWidget {
  const SilentPage(
      {super.key, required this.controller, required this.settings});

  final Controller controller;
  final Settings settings;

  @override
  State<SilentPage> createState() => _PageState();
}

class _PageState extends State<SilentPage> {
  bool isSending = false;

  int intensity = 10;
  int phase = 40;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Silencer'),
      ),
      body: Container(
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('intensity: $intensity'),
            Slider(
              value: intensity.toDouble(),
              min: 1,
              max: 255,
              divisions: 256,
              label: intensity.toString(),
              onChanged: (value) {
                setState(() {
                  intensity = value.toInt();
                });
              },
            ),
            Text('phase: $phase'),
            Slider(
              value: phase.toDouble(),
              min: 1,
              max: 255,
              divisions: 256,
              label: phase.toString(),
              onChanged: (value) {
                setState(() {
                  phase = value.toInt();
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isSending
            ? null
            : () async {
                setState(() {
                  isSending = true;
                });
                try {
                  await widget.controller.send(Silencer.fromCompletionTime(
                    Duration(microseconds: 25 * intensity),
                    Duration(microseconds: 25 * phase),
                  ));
                } catch (e) {
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString(),
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                      behavior: SnackBarBehavior.floating,
                      elevation: 4.0,
                      dismissDirection: DismissDirection.horizontal,
                    ),
                  );
                }
                setState(() {
                  isSending = false;
                });
              },
        child: isSending
            ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2.0),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Icon(Icons.send),
      ),
    );
  }
}
