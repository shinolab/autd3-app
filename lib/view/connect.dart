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
  bool _isValidIp = false;

  Settings settings = Settings();

  @override
  void initState() {
    super.initState();
    Future(() async {
      await settings.load('settings.json');
      setState(() {
        loading = false;
        _isValidIp = _ipv4Reg.hasMatch(settings.ip);
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
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Focus(
                    child: TextField(
                      controller: TextEditingController(text: settings.ip),
                      decoration: const InputDecoration(
                        labelText: 'IP Address of lightweight server',
                        hintText: 'xxx.xxx.xxx.xxx',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        settings.ip = value;
                      },
                      maxLength: 15,
                    ),
                    onFocusChange: (value) {
                      if (!value) {
                        setState(() {
                          _isValidIp = _ipv4Reg.hasMatch(settings.ip);
                        });
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Focus(
                    child: TextField(
                      controller:
                          TextEditingController(text: '${settings.port}'),
                      decoration: const InputDecoration(
                        labelText: 'Port of lightweight server',
                        hintText: '8080',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        settings.port = int.tryParse(value) ?? 8080;
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _isValidIp
                  ? () async {
                      await settings.save('settings.json');
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GeometryPage(
                              settings: settings,
                            ),
                          ));
                    }
                  : null,
              child: const Icon(Icons.navigate_next),
            ),
          );
  }
}
