import 'dart:async';

import 'package:coin_grant_anim/coin_grant_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class MyApp extends StatefulWidget {
  static GlobalKey storeBlockKey = GlobalKey();
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Container(),
        Positioned(
          top: 50,
          right: 30,
          child: storeBlock(),
        ),
        Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                OverlayEntry overlay = OverlayEntry(builder: (context) {
                  return CoinGrantAnimation(
                      initalPos: Offset(100, 500),
                      storeBlockKey: MyApp.storeBlockKey);
                });
                Overlay.of(context).insert(overlay);
                Timer(Duration(seconds: 4), () {
                  overlay.remove();
                });
              },
              child: Text("tap here"),
            ))
      ]),
    );
  }

  Widget storeBlock() {
    return Container(
      key: MyApp.storeBlockKey,
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
      child: Icon(
        Icons.shopping_cart_outlined,
        color: Colors.white,
      ),
    );
  }
}
