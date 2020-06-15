import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(MaterialApp(
  home: MyApp(),
  theme: ThemeData(
    canvasColor: Colors.blueGrey,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    accentColor: Colors.pinkAccent,
    brightness: Brightness.dark,
  ),
));

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class Timer {
  bool isPlaying = false;
  int minutes = 25;
}

class MyAppState extends State<MyApp> with TickerProviderStateMixin {
  AnimationController controller;
  Timer timer = new Timer();
  TextEditingController customController = new TextEditingController();

  // bool isPlaying = false;

  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: timer.minutes),
    );

    // ..addStatusListener((status) {
    //     if (controller.status == AnimationStatus.dismissed) {
    //       setState(() => isPlaying = false);
    //     }

    //     print(status);
    //   })
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: FractionalOffset.center,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: controller,
                          builder: (BuildContext context, Widget child) {
                            return CustomPaint(
                                painter: TimerPainter(
                                  animation: controller,
                                  backgroundColor: Colors.white,
                                  color: themeData.indicatorColor,
                                ));
                          },
                        ),
                      ),
                      Align(
                        alignment: FractionalOffset.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Count Down",
                              style: themeData.textTheme.subhead,
                            ),
                            GestureDetector(
                              onTap: () {
                                customController.clear();


                                showDialog(context: context, builder: (context) {
                                  return AlertDialog(
                                    title: Text("How many minutes?"),
                                    content: TextField(
                                      controller: customController,
                                      keyboardType: TextInputType.number,
                                      autofocus:true,
                                      onSubmitted: (String text) {
                                        submit();
                                        
                                      },
                                    ),
                                    actions: <Widget>[
                                      MaterialButton(
                                        elevation: 5.0,
                                        child: new Text("Submit"),
                                        onPressed: () {
                                          submit();
                                        },
                                      )
                                    ],
                                  );
                                });
                              },
                              child: AnimatedBuilder(
                                  animation: controller,
                                  builder: (BuildContext context, Widget child) {
                                    return Text(
                                      timerString,
                                      style: themeData.textTheme.display4,
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (BuildContext context, Widget child) {

                        return Icon(timer.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow);

                        // Icon(isPlaying
                        // ? Icons.pause
                        // : Icons.play_arrow);
                      },
                    ),
                    onPressed: () {
                      startStopTimer();
                    },
                  ),
                  FloatingActionButton(
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (BuildContext context, Widget child) {

                        return Icon(Icons.stop);

                        // Icon(isPlaying
                        // ? Icons.pause
                        // : Icons.play_arrow);
                      },
                    ),
                    onPressed: () {
                      timer.isPlaying = false;


                      setState(() {
                        controller.duration = Duration(minutes: timer.minutes);
                      });
                      controller.reset();
                      controller.reverse(
                          from: controller.value == 0.0
                              ? 1.0
                              : controller.value);
                      controller.stop();
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  void startStopTimer() {
    // setState(() => isPlaying = !isPlaying);
    setState(() {
      if (timer.isPlaying == true) {
        timer.isPlaying = false;
      }
      else {
        timer.isPlaying = true;
      }
    });

    if (controller.isAnimating) {
      controller.stop(canceled: true);
    } else {
      controller.reverse(
          from: controller.value == 0.0
              ? 1.0
              : controller.value);
    }
  }

  void submit() {
    Navigator.of(context).pop(customController.text.toString());
    timer.minutes = int.parse(customController.text);
    controller.duration = Duration(minutes: timer.minutes);

    controller.reset();
    startStopTimer();
    timer.isPlaying = true;
  }
}

class TimerPainter extends CustomPainter {
  TimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}