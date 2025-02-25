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
  final List<ControlPoints> _foci = [];

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('freq [Hz]: '),
                    // ignore: sized_box_for_whitespace
                    Container(
                      width: 60,
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
                                          _FociSTMAddPage(focus, "Edit", true)),
                                ).then((value) {
                                  if (value != null) {
                                    final (c, isUpdate) = value;
                                    setState(() {
                                      if (isUpdate) {
                                        _foci[index] = c;
                                      } else {
                                        _foci.removeAt(index);
                                      }
                                    });
                                  }
                                });
                              },
                              child: Dismissible(
                                key: ValueKey<ControlPoints>(focus),
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
                                ? ControlPoints([
                                    ControlPoint(
                                        pos: autd3.Point3(90, 70, 150),
                                        offset: null)
                                  ], intensity: EmitIntensity(255))
                                : _foci[_foci.length - 1];
                            final value = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      _FociSTMAddPage(lastFoci, "Add", false)),
                            );
                            if (value != null) {
                              final (c, isUpdate) = value;
                              if (isUpdate) {
                                setState(() {
                                  _foci.add(c);
                                });
                              }
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
                      .send(autd3.FociSTM(foci: _foci, config: freq.Hz));
                } catch (e) {
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString(),
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
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
  final ControlPoints p;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
            'Foci[$index]: (${p.points[0].pos.x}, ${p.points[0].pos.y}, ${p.points[0].pos.z}) with intensity = ${p.intensity?.value ?? 255}'),
      ),
    );
  }
}

class _FociSTMAddPage extends StatefulWidget {
  const _FociSTMAddPage(this.focus, this.title, this.isEditMode);

  final ControlPoints focus;
  final String title;
  final bool isEditMode;

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
    x = widget.focus.points[0].pos.x;
    y = widget.focus.points[0].pos.y;
    z = widget.focus.points[0].pos.z;
    intensity = widget.focus.intensity?.value ?? 255;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
            Text('Intensity: $intensity'),
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop((
                    ControlPoints([ControlPoint(pos: autd3.Point3(x, y, z))],
                        intensity: EmitIntensity(intensity)),
                    true
                  ));
                },
                child: widget.isEditMode
                    ? const Text('Update')
                    : const Text('Add'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop((null, false));
                },
                child: widget.isEditMode
                    ? const Text('Remove')
                    : const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
