import 'package:flutter/material.dart';

/// Kisi bhi sub-screen se Hub (0) ya Profile (1) tab par jaane ke liye
class AppNav {
  static void Function(int tab)? _setTab;

  static void register(void Function(int tab) cb) => _setTab = cb;
  static void unregister() => _setTab = null;

  static void goTab(BuildContext context, int tab) {
    Navigator.of(context)
        .popUntil((r) => r.isFirst || r.settings.name == 'client-home');
    _setTab?.call(tab);
  }
}