import 'package:flutter/material.dart';

class RootNavigatorKey {
  static GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static BuildContext get context => key.currentState!.overlay!.context;
}