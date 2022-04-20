import 'package:flutter/material.dart';

class BouncingGitCommit extends StatefulWidget {
  final double height;
  final double width;
  final Color circleColor;
  final Color lineColor;
  final Duration duration;

  const BouncingGitCommit({
    this.height = 200.0,
    this.width = 400.0,
    this.duration = const Duration(milliseconds: 350),
    this.circleColor = Colors.blueAccent,
    this.lineColor = Colors.deepOrange,
    Key? key,
  }) : super(key: key);

  @override
  State<BouncingGitCommit> createState() => _BouncingGitCommitState();
}

class _BouncingGitCommitState extends State<BouncingGitCommit>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> positionAnimation;

  void initializeAnimationController() {
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  void initializePositionAnimation() {
    positionAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  void init() {
    initializeAnimationController();
    initializePositionAnimation();
  }

  void clear() {
    controller.dispose();
  }

  @override
  void initState() {
    init();
    super.initState();
    // Starting animation
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedCommit(
        circleColor: widget.circleColor,
        lineColor: widget.lineColor,
        height: widget.height,
        width: widget.width,
        animation: positionAnimation,
      ),
    );
  }
}

class AnimatedCommit extends AnimatedWidget {
  final double height;
  final double width;
  final Color lineColor;
  final Color circleColor;

  const AnimatedCommit({
    required Animation<double> animation,
    Key? key,
    required this.height,
    required this.width,
    required this.lineColor,
    required this.circleColor,
  }) : super(listenable: animation, key: key);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: CommitPainter(
          circleColor: circleColor,
          lineColor: lineColor,
          circlePositionY: animation.value,
        ),
      ),
    );
  }
}

class CommitPainter extends CustomPainter {
  late final double circleRadius;
  late final double lineLength;
  late final double lineStrokeWidth;
  final double circlePadding = 16.0;
  final Color circleColor;
  final Color lineColor;
  final double circlePositionY;

  CommitPainter({
    this.circleColor = Colors.black,
    this.lineColor = Colors.black,
    this.circlePositionY = 0.0,
  });

  void init(Size size) {
    circleRadius = 0.115 * size.width;
    lineLength = (size.width / 2) - circlePadding - circleRadius;
    lineStrokeWidth = 0.08 * lineLength;
  }

  void drawHorizontalLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineStrokeWidth
      ..strokeCap = StrokeCap.round;

    // Left line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(lineLength, size.height / 2),
      paint,
    );

    // Right line
    canvas.drawLine(
      Offset(size.width / 2 + circleRadius + circlePadding, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  // Middle circle
  void drawCircle(Canvas canvas, Size size) {
    var x = size.width / 2 - 0;
    var y = size.height / 2 - circlePositionY;

    final paint = Paint()..color = circleColor;

    canvas.drawCircle(
      Offset(x, y),
      circleRadius,
      paint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    init(size);
    drawCircle(canvas, size);
    drawHorizontalLines(canvas, size);
  }

  @override
  bool shouldRepaint(CommitPainter oldDelegate) {
    // If circle position changes
    return circlePositionY != oldDelegate.circlePositionY;
  }

  @override
  bool shouldRebuildSemantics(CommitPainter oldDelegate) => false;
}
