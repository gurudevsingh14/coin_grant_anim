import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class CoinGrantAnimation extends StatefulWidget {
  final Offset initalPos;
  final GlobalKey storeBlockKey;

  const CoinGrantAnimation(
      {required this.initalPos, required this.storeBlockKey, Key? key})
      : super(key: key);

  @override
  State<CoinGrantAnimation> createState() => _CoinGrantAnimationState();
}

class _CoinGrantAnimationState extends State<CoinGrantAnimation>
    with TickerProviderStateMixin {
  int coinCount = 50;
  static const int GRANT_TIME = 3500;
  static const int ROTATE_TIME = 330;
  static const int FLYDELAY = 500;
  late AnimationController coinGrantAnimationController;
  late AnimationController coinRotationAnimationController;

  late Animation<double> coinRotationAnimation;
  late Animation<double> coinFadeInAnimation;
  late Animation<double> coinScaleUpAnimation;

  List<Animation<double>> coinPathAnimation = [];

  List<Path> coinPath = [];

  List<Offset> pauseMidOffset = [];

  Path getQuadraticBezierPath(Offset initial, Offset mid, Offset finalOff) {
    Path path = Path();
    path.moveTo(initial.dx, initial.dy);
    path.quadraticBezierTo(mid.dx, mid.dy, finalOff.dx, finalOff.dy);
    return path;
  }

  static Offset calculatePathOffset(double value, Path path) {
    PathMetrics pathMetrics = path.computeMetrics();
    PathMetric pathMetric = pathMetrics.elementAt(0);
    value = pathMetric.length * value;
    Tangent? pos = pathMetric.getTangentForOffset(value);
    return pos!.position;
  }

  double getRandomDoubleInRange(double min, double max) {
    final _random = Random();
    return _random.nextDouble() * (max - min) + min;
  }

  initAnimations() {
    coinGrantAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: GRANT_TIME),
    );
    coinRotationAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ROTATE_TIME),
    );

    const double DELAY = 70;
    double cummDelay = 0;
    Random random = Random();
    for (int i = 0; i < coinCount; i++) {
      coinPathAnimation.add(
        Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: coinGrantAnimationController,
            curve: Interval(cummDelay / GRANT_TIME, 1.0),
          ),
        ),
      );
      cummDelay += DELAY;

      Offset initalOffset = widget.initalPos;
      Offset midShiftOffset = initalOffset +
          Offset(
            getRandomDoubleInRange(-150, 150),
            random.nextDouble() * 500,
          );
      RenderBox box =
          widget.storeBlockKey.currentContext!.findRenderObject() as RenderBox;
      Offset storeIconPos = box.localToGlobal(Offset.zero);
      Size storeIconSize = box.size;

      Offset finalOffset = Offset(storeIconPos.dx, storeIconPos.dy);
      coinPath.add(
        getQuadraticBezierPath(
          initalOffset,
          midShiftOffset,
          finalOffset,
        ),
      );
      pauseMidOffset.add(initalOffset + midShiftOffset);
    }

    coinScaleUpAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: coinGrantAnimationController,
        curve: const Interval(0.0, 330 / GRANT_TIME, curve: Curves.easeInOut),
      ),
    );

    coinFadeInAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: coinGrantAnimationController,
        curve: const Interval(0.0, 165 / GRANT_TIME, curve: Curves.easeInOut),
      ),
    );

    coinRotationAnimation = Tween(begin: 0.0, end: pi).animate(
      CurvedAnimation(
        parent: coinRotationAnimationController,
        curve: const Interval(0.0, ROTATE_TIME / GRANT_TIME,
            curve: Curves.easeInOut),
      ),
    );

    coinRotationAnimationController.repeat();
  }

  @override
  void initState() {
    initAnimations();
    coinGrantAnimationController.forward(from: 0.0);
    super.initState();
  }

  @override
  void dispose() {
    coinGrantAnimationController.dispose();
    coinRotationAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [Expanded(child: Container()), ...getCoins()],
    );
  }

  List<Widget> getCoins() {
    List<Widget> coins = [];
    Offset oldPos = Offset.zero;
    for (int i = 0; i < coinCount; i++) {
      coins.add(AnimatedBuilder(
        animation: coinPathAnimation[i],
        builder: (context, child) {
          Offset newPos =
              calculatePathOffset(coinPathAnimation[i].value, coinPath[i]);
          return Positioned(
            top: newPos.dy,
            left: newPos.dx,
            child: getCoinWidget(),
          );
        },
      ));
    }
    return coins;
  }

  Widget getCoinWidget() {
    return ScaleTransition(
      scale: coinScaleUpAnimation,
      child: FadeTransition(
        opacity: coinFadeInAnimation,
        child: AnimatedBuilder(
          animation: coinRotationAnimation,
          builder: (_, __) {
            return Transform(
              transform: Matrix4.rotationY(coinRotationAnimation.value),
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/coin.png'),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
