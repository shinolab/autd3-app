import 'package:flutter/material.dart';

import 'package:autd3/autd3.dart';
import '../../settings.dart';

class BesselPage extends StatefulWidget {
  const BesselPage(
      {super.key, required this.controller, required this.settings});

  final Controller controller;
  final Settings settings;

  @override
  State<BesselPage> createState() => _BesselPageState();
}

class _BesselPageState extends State<BesselPage> {
  bool isSending = false;

  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  double nx = 0.0;
  double ny = 0.0;
  double nz = 1.0;
  double theta = 18.0;
  int intensity = 255;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bessel'),
      ),
      body: Container(
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Text('x: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: x.toString()),
                    onChanged: (value) {
                      x = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const Text('y: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: y.toString()),
                    onChanged: (value) {
                      y = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const Text('z: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: z.toString()),
                    onChanged: (value) {
                      z = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                const Text('nx: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: nx.toString()),
                    onChanged: (value) {
                      nx = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const Text('ny: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: ny.toString()),
                    onChanged: (value) {
                      ny = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const Text('nz: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: nz.toString()),
                    onChanged: (value) {
                      nz = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('theta: ${theta.toInt()} deg'),
            Slider(
              value: theta,
              min: 0,
              max: 90,
              divisions: 90,
              label: theta.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  theta = value;
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
                  await widget.controller.send(Bessel(
                    Vector3(x, y, z),
                    Vector3(nx, ny, nz),
                    theta.deg,
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
