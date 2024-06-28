import 'package:autd3/datagram/gain/holo/holo.dart';
import 'package:flutter/material.dart';

import 'package:autd3/autd3.dart' as autd3;
import '../../settings.dart';

class HoloPage extends StatefulWidget {
  const HoloPage({super.key, required this.controller, required this.settings});

  final autd3.Controller controller;
  final Settings settings;

  @override
  State<HoloPage> createState() => _HoloPageState();
}

// ignore: constant_identifier_names
enum HoloType { Greedy, GS, GSPAT, Naive, LM, SDP }

class _HoloPageState extends State<HoloPage> {
  bool isSending = false;

  final List<Holo> _foci = [];
  HoloType selectedAlgorighm = HoloType.GSPAT;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holo'),
      ),
      body: Container(
          padding: const EdgeInsets.all(64),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Algorithm"),
                DropdownButton<HoloType>(
                    alignment: Alignment.topRight,
                    value: selectedAlgorighm,
                    onChanged: (HoloType? newValue) {
                      setState(() {
                        selectedAlgorighm = newValue ?? HoloType.GSPAT;
                      });
                    },
                    items: HoloType.values.map((HoloType classType) {
                      return DropdownMenuItem<HoloType>(
                          value: classType,
                          child: Text(classType
                              .toString()
                              .replaceFirst("HoloType.", "")));
                    }).toList()),
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
                                          _HoloAddPage(focus)),
                                ).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      _foci[index] = value;
                                    });
                                  }
                                });
                              },
                              child: Dismissible(
                                key: ValueKey<Holo>(focus),
                                onDismissed: (direction) {
                                  setState(() {
                                    _foci.removeAt(index);
                                  });
                                },
                                child: HoloCard(index: index, holo: focus),
                              ));
                        },
                        shrinkWrap: true,
                        itemCount: _foci.length,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                          onPressed: () async {
                            final lastFoci = _foci.isEmpty
                                ? Holo(autd3.Vector3(90, 70, 150), 5e3.pa)
                                : _foci[_foci.length - 1];
                            final value = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => _HoloAddPage(lastFoci)),
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
                  switch (selectedAlgorighm) {
                    case HoloType.Greedy:
                      await widget.controller.send(autd3.Greedy(_foci));
                    case HoloType.GS:
                      await widget.controller.send(autd3.GS(_foci));
                    case HoloType.GSPAT:
                      await widget.controller.send(autd3.GSPAT(_foci));
                    case HoloType.Naive:
                      await widget.controller.send(autd3.Naive(_foci));
                    case HoloType.LM:
                      await widget.controller.send(autd3.LM(_foci));
                    case HoloType.SDP:
                      await widget.controller.send(autd3.SDP(_foci));
                  }
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

class HoloCard extends StatelessWidget {
  const HoloCard({super.key, required this.index, required this.holo});

  final int index;
  final Holo holo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
            'Foci[$index]: ${holo.amp.pa} Pa @ (${holo.pos.x}, ${holo.pos.y}, ${holo.pos.z})'),
      ),
    );
  }
}

class _HoloAddPage extends StatefulWidget {
  const _HoloAddPage(this.focus);

  final Holo focus;

  @override
  State<_HoloAddPage> createState() => _HoloAddPageState();
}

class _HoloAddPageState extends State<_HoloAddPage> {
  _HoloAddPageState();

  double x = 0;
  double y = 0;
  double z = 0;
  double amp = 0;

  @override
  void initState() {
    super.initState();
    x = widget.focus.pos.x;
    y = widget.focus.pos.y;
    z = widget.focus.pos.z;
    amp = widget.focus.amp.pa;
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
            Text('Amplitude [Pa]: $amp'),
            Expanded(
                child: Slider(
              value: amp,
              min: 0,
              max: 20e3,
              divisions: 1000,
              label: amp.toString(),
              onChanged: (value) {
                setState(() {
                  amp = value;
                });
              },
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(Holo(autd3.Vector3(x, y, z), amp.pa));
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
