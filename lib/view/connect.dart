import 'package:flutter/material.dart';

import '../settings.dart';
import 'geometry.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key, required this.title});

  final String title;

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final _ipv4Reg = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$');

  bool loading = true;
  String _ipAddress = '';
  bool _isValudIp = false;

  Settings settings = Settings();

  @override
  void initState() {
    super.initState();
    Future(() async {
      await settings.load('settings.json');
      setState(() {
        loading = false;
        _ipAddress = settings.ip;
        _isValudIp = _ipv4Reg.hasMatch(_ipAddress);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Focus(
                    child: TextField(
                      controller: TextEditingController(text: _ipAddress),
                      decoration: const InputDecoration(
                        labelText: 'Input IP Address of server',
                        hintText: 'xxx.xxx.xxx.xxx',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _ipAddress = value;
                      },
                      maxLength: 15,
                    ),
                    onFocusChange: (value) {
                      if (!value) {
                        setState(() {
                          _isValudIp = _ipv4Reg.hasMatch(_ipAddress);
                        });
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FilledButton(
                    onPressed: _isValudIp
                        ? () async {
                            final value = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GeometryPage(
                                    ipAddress: _ipAddress,
                                    settings: settings,
                                  ),
                                ));
                            if (value is Exception) {
                              if (!context.mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor:
                                      Colors.redAccent.withOpacity(0.8),
                                  content: Text('$value'),
                                ),
                              );
                            }
                          }
                        : null,
                    child: const Text('Connect'),
                  ),
                ],
              ),
            ));
  }
}
