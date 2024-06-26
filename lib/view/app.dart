import 'package:autd3_gui_app/view/gain.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:autd3/autd3.dart';

import '../settings.dart';
import 'config.dart';
import 'modulation.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key, required this.settings, required this.ipAddress});

  final Settings settings;
  final String ipAddress;

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  bool isSending = false;
  Controller? controller;

  @override
  void initState() {
    super.initState();
    Future(() async {
      await widget.settings.save('settings.json');
      return await Controller.builder(widget.settings.geometry.map((d) => AUTD3(
              Vector3(d.x, d.y, d.z),
              rot: Quaternion.axisAngle(Vector3(0, 0, 1), d.rz1) *
                  Quaternion.axisAngle(Vector3(0, 1, 0), d.ry) *
                  Quaternion.axisAngle(Vector3(0, 0, 1), d.rz2))))
          .open(ClientChannel(
        widget.ipAddress,
        port: 8080,
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
          connectTimeout: Duration(seconds: 10),
        ),
      ));
    }).then((value) => setState(() {
          controller = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return controller == null
        ? Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).indicatorColor,
                size: 100,
              ),
            ),
          )
        : PopScope(
            canPop: false,
            onPopInvoked: (bool didPop) async {
              if (didPop) {
                return;
              }
              final navigator = Navigator.of(context);
              final shouldPop = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Disconnect from ${widget.ipAddress}?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () async {
                          await controller?.close();
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );
              if (shouldPop ?? false) {
                navigator.pop();
              }
            },
            child: Column(children: <Widget>[
              Expanded(
                  child: DefaultTabController(
                      length: 3,
                      child: Scaffold(
                        appBar: AppBar(
                          title: const Text('AUTD3 App'),
                          bottom: const TabBar(
                            labelStyle: TextStyle(fontSize: 20),
                            isScrollable: true,
                            tabs: <Widget>[
                              Tab(text: 'Gain'),
                              Tab(text: 'Modulation'),
                              Tab(text: 'Config'),
                            ],
                          ),
                        ),
                        body: TabBarView(
                          children: <Widget>[
                            GainPage(
                                controller: controller!,
                                settings: widget.settings),
                            ModulationPage(
                                controller: controller!,
                                settings: widget.settings),
                            ConfigPage(
                                controller: controller!,
                                settings: widget.settings),
                          ],
                        ),
                      ))),
              Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          FloatingActionButton(
                              onPressed: isSending
                                  ? null
                                  : () async {
                                      setState(() {
                                        isSending = true;
                                      });
                                      await controller?.send(Null());
                                      await controller?.send(
                                          Silencer.fromCompletionSteps(10, 40));
                                      setState(() {
                                        isSending = false;
                                      });
                                      if (!context.mounted) {
                                        return;
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor:
                                              Colors.redAccent.withOpacity(0.8),
                                          content:
                                              const Text('Failed to send data'),
                                        ),
                                      );
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
                                  : const Icon(Icons.pause)),
                        ],
                      )))
            ]));
  }
}
