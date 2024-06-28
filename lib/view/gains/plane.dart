import 'package:flutter/material.dart';

import 'package:autd3/autd3.dart';
import '../../settings.dart';

class PlanePage extends StatefulWidget {
  const PlanePage(
      {super.key, required this.controller, required this.settings});

  final Controller controller;
  final Settings settings;

  @override
  State<PlanePage> createState() => _PlanePageState();
}

class _PlanePageState extends State<PlanePage> {
  bool isSending = false;

  double nx = 0.0;
  double ny = 0.0;
  double nz = 1.0;
  int intensity = 255;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plane'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('nx: $nx'),
            Slider(
              value: nx,
              min: 0,
              max: 1,
              divisions: 100,
              label: nx.toString(),
              onChanged: (value) {
                setState(() {
                  nx = value;
                });
              },
            ),
            Text('ny: $ny'),
            Slider(
              value: ny,
              min: 0,
              max: 1,
              divisions: 100,
              label: ny.toString(),
              onChanged: (value) {
                setState(() {
                  ny = value;
                });
              },
            ),
            Text('nz: $nz'),
            Slider(
              value: nz,
              min: 0,
              max: 1,
              divisions: 100,
              label: nz.toString(),
              onChanged: (value) {
                setState(() {
                  nz = value;
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
                  await widget.controller.send(Plane(
                    Vector3(nx, ny, nz),
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
