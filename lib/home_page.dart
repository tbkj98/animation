import 'package:flutter/material.dart';

import 'location_load_animation.dart';

class HomePage extends StatefulWidget {
  final controller = LocationLoadAnimationController();
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LocationLoadAnimation(
              duration: const Duration(milliseconds: 300),
              controller: widget.controller,
              pinColor: Colors.red,
            ),
            ControlButton(controller: widget.controller),
          ],
        ),
      ),
    );
  }
}

class ControlButton extends StatefulWidget {
  final LocationLoadAnimationController controller;
  const ControlButton({Key? key, required this.controller}) : super(key: key);

  @override
  State<ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<ControlButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => setState(() => widget.controller.isRunning()
          ? widget.controller.stop()
          : widget.controller.start()),
      child: widget.controller.isRunning()
          ? const Text('STOP')
          : const Text('START'),
    );
  }
}
