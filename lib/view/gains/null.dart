import 'package:flutter/material.dart';

import 'package:autd3/autd3.dart';
import '../../settings.dart';

class NullPage extends StatefulWidget {
  const NullPage({super.key, required this.controller, required this.settings});

  final Controller controller;
  final Settings settings;

  @override
  State<NullPage> createState() => _NullPageState();
}

class _NullPageState extends State<NullPage> {
  bool isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Null'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isSending
            ? null
            : () async {
                setState(() {
                  isSending = true;
                });
                try {
                  await widget.controller.send(Null());
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
