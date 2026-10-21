import 'package:eventra/app/router.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventraApp extends StatefulWidget {
  const EventraApp({super.key, this.router});

  /// Injected in tests; built once otherwise.
  final GoRouter? router;

  @override
  State<EventraApp> createState() => _EventraAppState();
}

class _EventraAppState extends State<EventraApp> {
  late final GoRouter _router = widget.router ?? buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Eventra',
      debugShowCheckedModeBanner: false,
      theme: buildEventraTheme(),
      routerConfig: _router,
    );
  }
}
