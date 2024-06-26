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
      body: Center(
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
                widget.controller
                    .send(Silencer.fromCompletionSteps(intensity, phase))
                    .then;
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
