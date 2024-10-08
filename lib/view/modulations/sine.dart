import 'package:flutter/material.dart';

import 'package:autd3/autd3.dart';
import '../../settings.dart';

class SinePage extends StatefulWidget {
  const SinePage({super.key, required this.controller, required this.settings});

  final Controller controller;
  final Settings settings;

  @override
  State<SinePage> createState() => _SinePageState();
}

class _SinePageState extends State<SinePage> {
  bool isSending = false;

  int freq = 150;
  int intensity = 255;
  int offset = 127;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sine'),
      ),
      body: Container(
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('freq [Hz]: '),
                // ignore: sized_box_for_whitespace
                Container(
                    width: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: freq.toString()),
                      onChanged: (value) {
                        freq = int.tryParse(value) ?? 0;
                      },
                    )),
              ],
            ),
            const SizedBox(height: 16),
            Text('intensity: $intensity'),
            Slider(
              value: intensity.toDouble(),
              min: 0,
              max: 255,
              divisions: 256,
              label: intensity.toString(),
              onChanged: (value) {
                setState(() {
                  intensity = value.toInt();
                });
              },
            ),
            Text('offset: $offset'),
            Slider(
              value: offset.toDouble(),
              min: 0,
              max: 256,
              divisions: 256,
              label: offset.toString(),
              onChanged: (value) {
                setState(() {
                  offset = value.toInt();
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
                  await widget.controller.send(Sine.create(
                    freq.Hz,
                    intensity: intensity,
                    offset: offset,
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
