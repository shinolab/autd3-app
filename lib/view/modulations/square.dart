import 'package:flutter/material.dart';

import 'package:autd3/autd3.dart';
import '../../settings.dart';

class SquarePage extends StatefulWidget {
  const SquarePage(
      {super.key, required this.controller, required this.settings});

  final Controller controller;
  final Settings settings;

  @override
  State<SquarePage> createState() => _SquarePageState();
}

class _SquarePageState extends State<SquarePage> {
  bool isSending = false;

  int freq = 150;
  int low = 0;
  int high = 255;
  double duty = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Square'),
      ),
      body: Center(
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
            Text('low: $low'),
            Slider(
              value: low.toDouble(),
              min: 0,
              max: 255,
              divisions: 256,
              label: low.toString(),
              onChanged: (value) {
                setState(() {
                  low = value.toInt();
                });
              },
            ),
            Text('high: $high'),
            Slider(
              value: high.toDouble(),
              min: 0,
              max: 256,
              divisions: 256,
              label: high.toString(),
              onChanged: (value) {
                setState(() {
                  high = value.toInt();
                });
              },
            ),
            Text('duty: $duty'),
            Slider(
              value: duty,
              min: 0,
              max: 1,
              divisions: 100,
              label: duty.toString(),
              onChanged: (value) {
                setState(() {
                  duty = value;
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
                  await widget.controller.send(Square.create(
                    freq.Hz,
                    low: low,
                    high: high,
                    duty: duty,
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
