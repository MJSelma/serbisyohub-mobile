import 'package:flutter/material.dart';
import '../api.dart';
import '../core/theme/app_theme.dart';
import 'main_shell.dart';

class SerbisyoHubApp extends StatefulWidget {
  const SerbisyoHubApp({super.key});
  @override
  State<SerbisyoHubApp> createState() => _SerbisyoHubAppState();
}

class _SerbisyoHubAppState extends State<SerbisyoHubApp> {
  late final AppSession session;
  @override
  void initState() {
    super.initState();
    session = AppSession()..restore();
  }

  @override
  void dispose() {
    session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: session,
    builder: (context, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SerbisyoHub',
      theme: AppTheme.light,
      home: session.loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : MainShell(session: session),
    ),
  );
}
