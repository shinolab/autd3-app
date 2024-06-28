import 'package:autd3/datagram/stm/control_point.dart';
import 'package:autd3/utils/emit_intensity.dart';
import 'package:flutter/material.dart';

import 'package:autd3/autd3.dart' as autd3;
import '../../settings.dart';

class FociSTMPage extends StatefulWidget {
  const FociSTMPage(
      {super.key, required this.controller, required this.settings});

  final autd3.Controller controller;
  final Settings settings;

  @override
  State<FociSTMPage> createState() => _FociSTMPageState();
}

class _FociSTMPageState extends State<FociSTMPage> {
  bool isSending = false;

  double freq = 1;
  final List<ControlPoints1> _foci = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FociSTM'),
      ),
      body: Container(
          padding: const EdgeInsets.all(64),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: [
                    const Text('Freqency [Hz]: '),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        controller:
                            TextEditingController(text: freq.toString()),
                        onChanged: (value) {
                          freq = double.tryParse(value) ?? 0;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Foci"),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          final focus = _foci[index];
                          return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          _FociSTMAddPage(focus)),
                                ).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      _foci[index] = value;
                                    });
                                  }
                                });
                              },
                              child: Dismissible(
                                key: ValueKey<ControlPoints1>(focus),
                                onDismissed: (direction) {
                                  setState(() {
                                    _foci.removeAt(index);
                                  });
                                },
                                child: FociSTMCard(index: index, p: focus),
                              ));
                        },
                        shrinkWrap: true,
                        itemCount: _foci.length,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                          onPressed: () async {
                            final lastFoci = _foci.isEmpty
                                ? ControlPoints1(
                                    ControlPoint(autd3.Vector3(90, 70, 150)),
                                    intensity: EmitIntensity(255))
                                : _foci[_foci.length - 1];
                            final value = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      _FociSTMAddPage(lastFoci)),
                            );
                            if (value != null) {
                              setState(() {
                                _foci.add(value);
                              });
                            }
                          },
                          child: const Icon(Icons.add))
                    ],
                  ),
                )
              ])),
      floatingActionButton: FloatingActionButton(
        onPressed: isSending
            ? null
            : () async {
                setState(() {
                  isSending = true;
                });
                try {
                  await widget.controller
                      .send(autd3.FociSTM1.fromFreq(freq.Hz, _foci));
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

class FociSTMCard extends StatelessWidget {
  const FociSTMCard({super.key, required this.index, required this.p});

  final int index;
  final ControlPoints1 p;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
            'Foci[$index]: (${p.points.pos.x}, ${p.points.pos.y}, ${p.points.pos.z})'),
      ),
    );
  }
}

class _FociSTMAddPage extends StatefulWidget {
  const _FociSTMAddPage(this.focus);

  final ControlPoints1 focus;

  @override
  State<_FociSTMAddPage> createState() => _FociSTMAddPageState();
}

class _FociSTMAddPageState extends State<_FociSTMAddPage> {
  _FociSTMAddPageState();

  double x = 0;
  double y = 0;
  double z = 0;
  int intensity = 0;

  @override
  void initState() {
    super.initState();
    x = widget.focus.points.pos.x;
    y = widget.focus.points.pos.y;
    z = widget.focus.points.pos.z;
    intensity = widget.focus.intensity?.value ?? 255;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add focus'),
      ),
      body: Container(
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('x: $x'),
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
            Text('y: $y'),
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
            Text('z: $z'),
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
            Text('Intensity: $intensity'),
            Expanded(
                child: Slider(
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
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(ControlPoints1(
                      ControlPoint(autd3.Vector3(x, y, z)),
                      intensity: EmitIntensity(intensity)));
                },
                child: const Text('Add'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
