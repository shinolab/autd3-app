import 'package:autd3/utils/emit_intensity.dart';
import 'package:flutter/material.dart';

import 'package:autd3/autd3.dart' as autd3;
import '../../settings.dart';

class FocusPage extends StatefulWidget {
  const FocusPage(
      {super.key, required this.controller, required this.settings});

  final autd3.Controller controller;
  final Settings settings;

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  bool isSending = false;

  double x = 0.0;
  double y = 0.0;
  double z = 200.0;
  int intensity = 255;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('x: $x'),
            Row(
              children: <Widget>[
                Expanded(
                    child: Slider(
                  value: x,
                  min: -500,
                  max: 500,
                  divisions: 1000,
                  label: x.toString(),
                  onChanged: (value) {
                    setState(() {
                      x = value;
                    });
                  },
                )),
                IconButton(
                    onPressed: () {
                      setState(() {
                        x = 0;
                      });
                    },
                    icon: const Icon(Icons.center_focus_strong))
              ],
            ),
            Text('y: $y'),
            Row(
              children: <Widget>[
                Expanded(
                    child: Slider(
                  value: y,
                  min: -500,
                  max: 500,
                  divisions: 1000,
                  label: y.toString(),
                  onChanged: (value) {
                    setState(() {
                      y = value;
                    });
                  },
                )),
                IconButton(
                    onPressed: () {
                      setState(() {
                        y = 0;
                      });
                    },
                    icon: const Icon(Icons.center_focus_strong))
              ],
            ),
            Text('z: $z'),
            Slider(
              value: z,
              min: 0,
              max: 1000,
              divisions: 1000,
              label: z.toString(),
              onChanged: (value) {
                setState(() {
                  z = value;
                });
              },
            ),
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
              onChangeEnd: (value) {},
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
                  await widget.controller.send(autd3.Focus(
                    autd3.Vector3(x, y, z),
                    intensity: EmitIntensity(intensity),
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
