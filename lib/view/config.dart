import 'package:flutter/material.dart';

import 'package:autd3/autd3.dart';
import '../settings.dart';
import 'configs/silent.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({Key? key, required this.controller, required this.settings})
      : super(key: key);

  final Controller controller;
  final Settings settings;

  @override
  State<ConfigPage> createState() => _PageState();
}

class _PageState extends State<ConfigPage> {
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
                                      builder: (context) => SilentPage(
                                          controller: widget.controller,
                                          settings: widget.settings)))
                            },
                        child: const Text('Silent',
                            style: TextStyle(fontSize: 14)))),
              ],
            ))
          ],
        ));
  }
}
