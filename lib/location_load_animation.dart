import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum AnimationState { running, idle }

/// Animation controller
/// User can call methods to start and stop the animation
/// Instance of this class must be provided if user want to control the animation
/// Otherwise animation will run infinitely
class LocationLoadAnimationController {
  final _isStart = ValueNotifier<AnimationState>(AnimationState.idle);
  VoidCallback? _listener;

  void start() {
    _isStart.value = AnimationState.running;
  }

  bool isRunning() => _isStart.value == AnimationState.running;

  void stop() {
    _isStart.value = AnimationState.idle;
  }

  void dispose() {
    removeListener();
    _isStart.dispose();
  }

  void addListener(VoidCallback callback) {
    if (_listener == null) {
      _listener = callback;
      _isStart.addListener(callback);
      return;
    }

    throw Exception('Multiple listeners not allowed.');
  }

  void removeListener() {
    if (_listener != null) {
      _isStart.removeListener(_listener!);
      _listener = null;
    }
  }
}

/// Animation widget class
class LocationLoadAnimation extends StatefulWidget {
  final double pinShadowWidth;
  final double pinShadowHeight;
  final double initialShadowSize;
  final double pinTranslation;
  final double shadowInitialScale;
  final double shadowFinalScale;
  final Duration duration;
  final LocationLoadAnimationController? controller;
  final Color? pinColor;

  const LocationLoadAnimation({
    this.initialShadowSize = 50.0,
    this.pinShadowHeight = 20.0,
    this.pinShadowWidth = 50.0,
    this.pinTranslation = 100.0,
    this.shadowFinalScale = 2.0,
    this.shadowInitialScale = 1.0,
    this.controller,
    required this.duration,
    this.pinColor,
    Key? key,
  }) : super(key: key);

  @override
  State<LocationLoadAnimation> createState() {
    return _LocationLoadAnimationState();
  }
}

class _LocationLoadAnimationState extends State<LocationLoadAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<RelativeRect> _positionAnimation;
  late final Animation<double> _scaleAnimation;
  late final VoidCallback listener;

  RelativeRect _getRelativeRect(
      {left = 0.0, top = 0.0, right = 0.0, bottom = 0.0}) {
    return RelativeRect.fromLTRB(left, top, right, bottom);
  }

  // Creating animation controller
  AnimationController _getAnimationController(Duration duration) {
    return AnimationController(
      vsync: this,
      duration: duration,
    );
  }

  // Animation to move location pin up and down
  Animation<RelativeRect> _getPositionAnimation(AnimationController ctrlr) {
    final top = -(widget.initialShadowSize + widget.pinTranslation);
    return RelativeRectTween(
      begin: _getRelativeRect(top: -widget.initialShadowSize),
      end: _getRelativeRect(top: top),
    ).animate(CurvedAnimation(parent: ctrlr, curve: Curves.easeOutSine));
  }

  // Animation to scale the pin shadow
  Animation<double> _getScaleAnimatin(double begin, double end) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutSine));
  }

  // Adding listeners to primary location controller(LocationLoadAnimationController)
  // We can start/stop the animation upon any change in primary controller
  void _addStartStopListener() {
    if (widget.controller == null) return;
    listener = () {
      bool val = widget.controller?.isRunning() ?? false;
      val ? _controller.repeat(reverse: true) : _controller.stop();
    };
    widget.controller?.addListener(listener);
  }

  // Animation widget width
  double _getWidgetWidth() {
    return ((widget.initialShadowSize * widget.shadowFinalScale) + 50.0);
  }

  // Animation widget height
  double _getWidgetHeight() {
    final t = widget.initialShadowSize * widget.shadowFinalScale;
    return t + widget.pinTranslation + 50.0;
  }

  @override
  void initState() {
    _controller = _getAnimationController(widget.duration);
    _positionAnimation = _getPositionAnimation(_controller);
    _scaleAnimation = _getScaleAnimatin(
      widget.shadowInitialScale,
      widget.shadowFinalScale,
    );
    _addStartStopListener();
    super.initState();
  }

  @override
  void dispose() {
    widget.controller?.removeListener();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startAnimation() async {
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    // If there is no controller
    // Animation will start after build method call
    if (widget.controller == null) _startAnimation();

    return SizedBox(
      width: _getWidgetWidth(),
      height: _getWidgetHeight(),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: widget.pinShadowWidth,
                height: widget.pinShadowHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(
                      widget.pinShadowWidth,
                      widget.pinShadowHeight,
                    ),
                  ),
                ),
              ),
            ),
          ),
          PositionedTransition(
            rect: _positionAnimation,
            child: Icon(
              FontAwesomeIcons.locationPin,
              size: widget.initialShadowSize,
              color: widget.pinColor ?? Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
