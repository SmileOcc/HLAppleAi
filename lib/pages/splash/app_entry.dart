import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../guide/guide_page.dart';
import '../main/main_page.dart';

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool? _seenOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('has_seen_onboarding') ?? false;
    if (!mounted) return;
    setState(() => _seenOnboarding = seen);
  }

  @override
  Widget build(BuildContext context) {
    if (_seenOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_seenOnboarding!) {
      return const MainPage();
    }
    return const GuidePage();
  }
}
