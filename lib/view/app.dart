import 'package:autd3_gui_app/settings.dart';
import 'package:autd3_gui_app/view/gain.dart';
import 'package:autd3_gui_app/view/stm.dart';
import 'package:flutter/material.dart';
import 'package:autd3/autd3.dart';
import 'dart:ui';

import 'config.dart';
import 'modulation.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key, required this.settings, required this.controller});

  final Settings settings;
  final Controller controller;

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  bool isSending = false;
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onExitRequested: _handleExitRequest,
    );
  }

  Future<AppExitResponse> _handleExitRequest() async {
    await widget.controller.close();
    return AppExitResponse.exit;
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
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
                title: Text(
                    'Disconnect from ${widget.settings.ip}:${widget.settings.port}?'),
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
                      try {
                        await widget.controller.close();
                      } catch (_) {}
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
                  length: 4,
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text('AUTD3 App'),
                      bottom: const TabBar(
                        labelStyle: TextStyle(fontSize: 20),
                        isScrollable: true,
                        tabs: <Widget>[
                          Tab(text: 'Gain'),
                          Tab(text: 'Modulation'),
                          Tab(text: 'STM'),
                          Tab(text: 'Config'),
                        ],
                      ),
                    ),
                    body: TabBarView(
                      children: <Widget>[
                        GainPage(
                            controller: widget.controller,
                            settings: widget.settings),
                        ModulationPage(
                            controller: widget.controller,
                            settings: widget.settings),
                        STMPage(
                            controller: widget.controller,
                            settings: widget.settings),
                        ConfigPage(
                            controller: widget.controller,
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
                                  try {
                                    await widget.controller.send(Null());
                                    await widget.controller.send(
                                        Silencer.fromCompletionSteps(10, 40));
                                  } catch (e) {
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString(),
                                            style: const TextStyle(
                                                color: Colors.white)),
                                        backgroundColor:
                                            Colors.redAccent.withOpacity(0.8),
                                        behavior: SnackBarBehavior.floating,
                                        elevation: 4.0,
                                        dismissDirection:
                                            DismissDirection.horizontal,
                                      ),
                                    );
                                  }
                                  setState(() {
                                    isSending = false;
                                  });
                                },
                          child: isSending
                              ? const CircularProgressIndicator()
                              : const Icon(Icons.pause)),
                    ],
                  )))
        ]));
  }
}
