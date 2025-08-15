import 'package:flutter/material.dart';
import 'package:taski/main.dart';

push(Widget screen) {
  navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) {
    return screen;
  }));
}

pushAndReplace(Widget screen) {
  navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (context) {
    return screen;
  }));
}

pushAndRemoveUntil(Widget screen) {
  navigatorKey.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (ctx) {
    return screen;
  }), (route) => false);
}

pop() {
  navigatorKey.currentState!.pop();
}