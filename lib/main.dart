import 'package:coin_grant_anim/coin_grant_animation.dart';
import 'package:flutter/material.dart';

import 'my_app.dart';

void main() {
  runApp(const MyAppMain());
}

class MyAppMain extends StatelessWidget {
  const MyAppMain({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyApp(),
    );
  }
}
