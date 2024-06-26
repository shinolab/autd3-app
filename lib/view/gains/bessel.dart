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
            Row(
              children: <Widget>[
                Expanded(
                    child: Slider(
                  value: z,
                  min: -500,
                  max: 500,
                  divisions: 1000,
                  label: z.toString(),
                  onChanged: (value) {
                    setState(() {
                      z = value;
                    });
                  },
                )),
                IconButton(
                    onPressed: () {
                      setState(() {
                        z = 0;
                      });
                    },
                    icon: const Icon(Icons.center_focus_strong))
              ],
            ),
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
            Text('theta: $theta'),
            Slider(
              value: theta,
              min: 0,
              max: 360,
              divisions: 360,
              label: theta.toString(),
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
                await widget.controller.send(Bessel(
                  Vector3(x, y, z),
                  Vector3(nx, ny, nz),
                  theta.deg,
                  intensity: EmitIntensity(intensity),
                ));
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
