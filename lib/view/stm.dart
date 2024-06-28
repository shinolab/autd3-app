import 'package:autd3_gui_app/view/stm/foci.dart';
import 'package:flutter/material.dart';

import 'package:autd3/autd3.dart';
import '../settings.dart';

class STMPage extends StatefulWidget {
  const STMPage({super.key, required this.controller, required this.settings});

  final Controller controller;
  final Settings settings;

  @override
  State<STMPage> createState() => _PageState();
}

class _PageState extends State<STMPage> {
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
                                      builder: (context) => FociSTMPage(
                                          controller: widget.controller,
                                          settings: widget.settings)))
                            },
                        child: const Text('FociSTM',
                            style: TextStyle(fontSize: 14)))),
              ],
            ))
          ],
        ));
  }
}
