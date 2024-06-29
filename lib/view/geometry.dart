import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:autd3/autd3.dart';
import 'package:grpc/grpc.dart';

import '../settings.dart';
import 'app.dart';

class GeometryPage extends StatefulWidget {
  const GeometryPage({super.key, required this.settings});

  final Settings settings;

  @override
  State<GeometryPage> createState() => _GeometryPageState();
}

class _GeometryPageState extends State<GeometryPage> {
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Geometry configuration'),
        ),
        body: Container(
            padding: const EdgeInsets.all(16),
            child: Column(children: <Widget>[
              const SizedBox(height: 16),
              ReorderableListView.builder(
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final Geometry item =
                        widget.settings.geometry.removeAt(oldIndex);
                    widget.settings.geometry.insert(newIndex, item);
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  final geometry = widget.settings.geometry[index];
                  return InkWell(
                      key: Key('$index'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => _GeometryConfigPage(
                                    geometry,
                                    'Edit',
                                    true,
                                  )),
                        ).then((value) {
                          if (value != null) {
                            final (g, isUpdate) = value;
                            setState(() {
                              if (isUpdate) {
                                widget.settings.geometry[index] = g;
                              } else {
                                widget.settings.geometry.removeAt(index);
                              }
                            });
                          }
                        });
                      },
                      child: Dismissible(
                        key: ValueKey<Geometry>(geometry),
                        onDismissed: (direction) {
                          setState(() {
                            widget.settings.geometry.removeAt(index);
                          });
                        },
                        child: GeometryCard(
                          index: index,
                          geometry: geometry,
                        ),
                      ));
                },
                shrinkWrap: true,
                itemCount: widget.settings.geometry.length,
              ),
              const SizedBox(height: 16),
              FilledButton(
                  onPressed: () async {
                    final value = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => _GeometryConfigPage(
                                Geometry(
                                    x: 0, y: 0, z: 0, ry: 0, rz1: 0, rz2: 0),
                                'Add',
                                false,
                              )),
                    );
                    if (value != null) {
                      final (g, isUpdate) = value;
                      if (isUpdate) {
                        setState(() {
                          widget.settings.geometry.add(g);
                        });
                      }
                    }
                  },
                  child: const Icon(Icons.add))
            ])),
        floatingActionButton: FloatingActionButton(
          backgroundColor: widget.settings.geometry.isEmpty || _connecting
              ? Theme.of(context).disabledColor
              : Theme.of(context).floatingActionButtonTheme.backgroundColor,
          onPressed: widget.settings.geometry.isEmpty || _connecting
              ? null
              : () async {
                  setState(() {
                    _connecting = true;
                  });
                  await widget.settings.save('settings.json');
                  Controller.builder(widget.settings.geometry.map((d) => AUTD3(
                          Vector3(d.x, d.y, d.z),
                          rot: Quaternion.axisAngle(
                                  Vector3(0, 0, 1), d.rz1 / 180 * pi) *
                              Quaternion.axisAngle(
                                  Vector3(0, 1, 0), d.ry / 180 * pi) *
                              Quaternion.axisAngle(
                                  Vector3(0, 0, 1), d.rz2 / 180 * pi))))
                      .open(ClientChannel(
                    widget.settings.ip,
                    port: widget.settings.port,
                    options: const ChannelOptions(
                      credentials: ChannelCredentials.insecure(),
                      connectTimeout: Duration(seconds: 10),
                    ),
                  ))
                      .then((controller) {
                    final completer = Completer();
                    final result = Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppPage(
                            settings: widget.settings,
                            controller: controller,
                          ),
                        ),
                        result: completer.future);
                    completer.complete(result);
                  }).catchError((e) {
                    setState(() {
                      _connecting = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to connect to the server: $e',
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                        duration: const Duration(days: 365),
                        behavior: SnackBarBehavior.floating,
                        elevation: 4.0,
                        closeIconColor: Colors.white,
                        showCloseIcon: true,
                        dismissDirection: DismissDirection.horizontal,
                      ),
                    );
                  });
                },
          child: _connecting
              ? const CircularProgressIndicator()
              : const Icon(Icons.navigate_next),
        ),
      ),
    );
  }
}

class GeometryCard extends StatelessWidget {
  const GeometryCard({super.key, required this.index, required this.geometry});

  final int index;
  final Geometry geometry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Device $index'),
        subtitle: Text(
            'pos: (${geometry.x}, ${geometry.y}, ${geometry.z}), rot: (${geometry.rz1}, ${geometry.ry}, ${geometry.rz2})'),
      ),
    );
  }
}

class _GeometryConfigPage extends StatefulWidget {
  const _GeometryConfigPage(this.geometry, this.title, this.isEditMode);

  final Geometry geometry;
  final String title;
  final bool isEditMode;

  @override
  State<_GeometryConfigPage> createState() => _GeometryConfigPageState();
}

class _GeometryConfigPageState extends State<_GeometryConfigPage> {
  _GeometryConfigPageState();

  Geometry geometry = Geometry(x: 0, y: 0, z: 0, ry: 0, rz1: 0, rz2: 0);

  @override
  void initState() {
    super.initState();
    geometry = widget.geometry;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.white,
                    width: 1.0,
                  ),
                ),
              ),
              child: const Text('Position',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.left),
            ),
            Row(
              children: [
                const Text('x: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller:
                        TextEditingController(text: geometry.x.toString()),
                    onChanged: (value) {
                      geometry.x = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.x += 192;
                      });
                    },
                    child: const Text('+W')),
                const SizedBox(width: 4),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.x += 151.4;
                      });
                    },
                    child: const Text('+H'))
              ],
            ),
            Row(
              children: [
                const Text('y: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller:
                        TextEditingController(text: geometry.y.toString()),
                    onChanged: (value) {
                      geometry.y = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.y += 192;
                      });
                    },
                    child: const Text('+W')),
                const SizedBox(width: 4),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.y += 151.4;
                      });
                    },
                    child: const Text('+H'))
              ],
            ),
            Row(
              children: [
                const Text('z: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller:
                        TextEditingController(text: geometry.z.toString()),
                    onChanged: (value) {
                      geometry.z = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.z += 192;
                      });
                    },
                    child: const Text('+W')),
                const SizedBox(width: 4),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.z += 151.4;
                      });
                    },
                    child: const Text('+H'))
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(bottom: 0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.white,
                    width: 1.0,
                  ),
                ),
              ),
              child: const Text('Rotation',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.left),
            ),
            Row(
              children: [
                const Text('rz1: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller:
                        TextEditingController(text: geometry.rz1.toString()),
                    onChanged: (value) {
                      geometry.rz1 = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.rz1 += 90;
                      });
                    },
                    child: const Text('+90°')),
              ],
            ),
            Row(
              children: [
                const Text(' ry: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller:
                        TextEditingController(text: geometry.ry.toString()),
                    onChanged: (value) {
                      geometry.ry = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.ry += 90;
                      });
                    },
                    child: const Text('+90°')),
              ],
            ),
            Row(
              children: [
                const Text('rz2: '),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller:
                        TextEditingController(text: geometry.rz2.toString()),
                    onChanged: (value) {
                      geometry.rz2 = double.tryParse(value) ?? 0;
                    },
                  ),
                ),
                FilledButton(
                    onPressed: () {
                      setState(() {
                        geometry.rz2 += 90;
                      });
                    },
                    child: const Text('+90°')),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop((geometry, true));
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
