import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:workmanager/workmanager.dart';


import 'package:flutter_dnd/flutter_dnd.dart';

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

    controller.addStatusListener((status) {
      if(status == AnimationStatus.dismissed) {
        disableDoNotDisturb();

        playAlarm();
      }
    });

    startStopTimer();
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

                        return Icon(Icons.stop);},
                    ),
                    onPressed: () {
                      timer.isPlaying = false;
                      disableDoNotDisturb();


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
  void startStopTimer() async {
    // setState(() => isPlaying = !isPlaying);

    controller.duration = Duration(seconds: 5);
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

    if (await FlutterDnd.isNotificationPolicyAccessGranted) {
      if(timer.isPlaying) {
        await FlutterDnd.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_PRIORITY);
      }
      else {
        await FlutterDnd.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_ALL);
      }
    }
    else {
      FlutterDnd.gotoPolicySettings();
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

  void disableDoNotDisturb() async {
    if (await FlutterDnd.isNotificationPolicyAccessGranted) {
      await FlutterDnd.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_ALL);
    }
    else {
      FlutterDnd.gotoPolicySettings();
    }
  }

  void playAlarm() {
    FlutterRingtonePlayer.play(
      android: AndroidSounds.ringtone,
      ios: IosSounds.glass,
      looping: true, // Android only - API >= 28
      volume: 1, // Android only - API >= 28
      asAlarm: true, // Android only - all APIs
    );

    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("How many minutes?"),
        content: Text("Stop sound?"),
        actions: <Widget>[
          MaterialButton(
            elevation: 5.0,
            child: new Text("STOP!"),
            onPressed: () {
              FlutterRingtonePlayer.stop();
              Navigator.pop(context);
            },
          )
        ],
      );
    });
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