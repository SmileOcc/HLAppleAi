import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS) {
    WebKitWebViewPlatform.registerWith();
  }

  runApp(const HLAppleAiApp());
}
