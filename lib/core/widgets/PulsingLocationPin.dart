// lib/features/location/widgets/pulsing_location_pin.dart

import 'package:flutter/material.dart';

class PulsingLocationPin extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const PulsingLocationPin({
    super.key,
    this.color = Colors.black,
    this.size = 40, // smaller default size
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<PulsingLocationPin> createState() => _PulsingLocationPinState();
}

class _PulsingLocationPinState extends State<PulsingLocationPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPulse(double delay) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, 1.0, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.5, end: 0.0).animate(animation),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.7, end: 1.4).animate(animation),
        child: Container(
          width: widget.size * 1.4,
          height: widget.size * 1.4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final circleSize = widget.size * 0.6;
    final stickHeight = widget.size * 0.7;

    return SizedBox(
      width: widget.size,
      height: widget.size * 1.5, // enough space for stick
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Pulses behind
          Positioned.fill(child: _buildPulse(0.0)),
          Positioned.fill(child: _buildPulse(0.5)),

          // Pin circle
          Positioned(
            top: 0,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: CircleAvatar(radius: 2, backgroundColor: Colors.white),
              ),
            ),
          ),

          // Stick
          Positioned(
            top: circleSize - 2,
            child: Container(
              width: 3,
              height: stickHeight,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}
