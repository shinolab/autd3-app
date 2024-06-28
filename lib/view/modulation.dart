import 'package:flutter/material.dart';

import 'package:autd3/autd3.dart';
import '../settings.dart';
import 'modulations/sine.dart';
import 'modulations/static.dart';
import 'modulations/square.dart';

class ModulationPage extends StatefulWidget {
  const ModulationPage(
      {super.key, required this.controller, required this.settings});

  final Controller controller;
  final Settings settings;

  @override
  State<ModulationPage> createState() => _ModulationPageState();
}

class _ModulationPageState extends State<ModulationPage> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 20),
            SingleChildScrollView(
                child: Wrap(
              runSpacing: 16,
              spacing: 16,
              children: <Widget>[
                SizedBox(
                    child: FilledButton(
                        onPressed: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SinePage(
                                          controller: widget.controller,
                                          settings: widget.settings)))
                            },
                        child: const Text('Sine',
                            style: TextStyle(fontSize: 14)))),
                SizedBox(
                    child: FilledButton(
                        onPressed: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SquarePage(
                                          controller: widget.controller,
                                          settings: widget.settings)))
                            },
                        child: const Text('Square',
                            style: TextStyle(fontSize: 14)))),
                SizedBox(
                    child: FilledButton(
                        onPressed: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StaticPage(
                                          controller: widget.controller,
                                          settings: widget.settings)))
                            },
                        child: const Text('Static',
                            style: TextStyle(fontSize: 14)))),
              ],
            ))
          ],
        ));
  }
}
