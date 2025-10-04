// lib/features/location/widgets/custom_marker.dart

import 'package:flutter/material.dart';

class CustomMarker extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const CustomMarker({
    super.key,
    required this.icon,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      // Using a Stack to layer the shadow, circle, and icon
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The "pin" shape at the bottom
          Positioned(
            bottom: 35,
            child: Transform.rotate(
              angle: 3.14159 / 4, // 45 degrees
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topRight: Radius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          // Main circle with a shadow
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
