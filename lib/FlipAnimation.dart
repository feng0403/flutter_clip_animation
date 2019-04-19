import 'package:flutter/material.dart';
import 'dart:math' as math;

enum FlipAnimationSteps { animation_step_1, animation_step_2, animation_step_3 }

FlipAnimationSteps currentFlipAnimationStep =
    FlipAnimationSteps.animation_step_1;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'flutter',
        home: Scaffold(
            appBar: AppBar(
              title: Text('Animation'),
            ),
            body: Center(
              child: FlipAnimationApp(),
            )));
  }
}

class FlipAnimationApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FlipAnimationApp();
  }
}

class _FlipAnimationApp extends State<FlipAnimationApp>
    with SingleTickerProviderStateMixin {
  var imageWidget = Image.asset(
    'images/mario.jpg',
    width: 300.0,
    height: 300.0,
  );

  AnimationController controller;

  CurvedAnimation animation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          switch (currentFlipAnimationStep) {
            case FlipAnimationSteps.animation_step_1:
              currentFlipAnimationStep = FlipAnimationSteps.animation_step_2;
              controller.reset();
              controller.forward();
              break;

            case FlipAnimationSteps.animation_step_2:
              currentFlipAnimationStep = FlipAnimationSteps.animation_step_3;
              controller.reset();
              controller.forward();
              break;
            case FlipAnimationSteps.animation_step_3:
              break;
          }
        }
      });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimateFlipWidget(
      animation: animation,
      child: imageWidget,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class AnimateFlipWidget extends AnimatedWidget {
  final Widget child;

  double _currentTopRotationXRadian = 0;
  double _currentBottomRotationXRadian = 0;
  double _currentRotationZRadian = 0;

  static final _topRotationXRadianTween =
      Tween<double>(begin: 0, end: math.pi / 4);
  static final _bottomRotationXRadianTween =
      Tween<double>(begin: 0, end: -math.pi / 4);
  static final _rotationZRadianTween =
      Tween<double>(begin: 0, end: (1 + 1 / 2) * math.pi);

  AnimateFlipWidget({Key key, Animation<double> animation, this.child})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;

    return Center(
      child: Container(
        child: Stack(
          children: [
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(currentFlipAnimationStep ==
                      FlipAnimationSteps.animation_step_2
                  ? _rotationZRadianTween.evaluate(animation) * -1
                  : _currentRotationZRadian * -1),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateX(currentFlipAnimationStep ==
                          FlipAnimationSteps.animation_step_3
                      ? _currentTopRotationXRadian =
                          _topRotationXRadianTween.evaluate(animation)
                      : _currentTopRotationXRadian),
                alignment: Alignment.center,
                child: ClipRect(
                  clipper: _TopClipper(context),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationZ(currentFlipAnimationStep ==
                            FlipAnimationSteps.animation_step_2
                        ? _currentRotationZRadian =
                            _rotationZRadianTween.evaluate(animation)
                        : _currentRotationZRadian),
                    child: child,
                  ),
                ),
              ),
            ),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(currentFlipAnimationStep ==
                      FlipAnimationSteps.animation_step_2
                  ? _rotationZRadianTween.evaluate(animation) * -1
                  : _currentRotationZRadian * -1),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateX(currentFlipAnimationStep ==
                          FlipAnimationSteps.animation_step_1
                      ? _currentBottomRotationXRadian =
                          _bottomRotationXRadianTween.evaluate(animation)
                      : _currentBottomRotationXRadian),
                alignment: Alignment.center,
                child: ClipRect(
                  clipper: _BottomClipper(context),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationZ(currentFlipAnimationStep ==
                            FlipAnimationSteps.animation_step_2
                        ? _currentRotationZRadian =
                            _rotationZRadianTween.evaluate(animation)
                        : _currentRotationZRadian),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopClipper extends CustomClipper<Rect> {
  final BuildContext context;

  _TopClipper(this.context);

  @override
  Rect getClip(Size size) {
    return new Rect.fromLTRB(
        -size.width, -size.height / 2, size.width * 2, size.height / 2);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class _BottomClipper extends CustomClipper<Rect> {
  final BuildContext context;

  _BottomClipper(this.context);

  @override
  Rect getClip(Size size) {
    return new Rect.fromLTRB(
        -size.width, size.height / 2, size.width * 2, size.height * 2);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
