// lib/features/location/widgets/image_asset_marker.dart

import 'package:flutter/material.dart';

class ImageAssetMarker extends StatelessWidget {
  final String assetPath;

  const ImageAssetMarker({
    super.key,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    // A Stack is used to perfectly align the pin's tip.
    // The map anchor point is the center of the Marker widget's space,
    // so we need to shift the image up so its tip is at the center.
    return Stack(
      children: [
        Positioned(
          // Horizontally center the image
          left: 0,
          right: 0,
          // Position the bottom of the image at the vertical center of the Stack
          bottom: 0,
          child: Image.asset(
            assetPath,
            // We can optionally set the width here if the marker size isn't enough
            // width: 50,
          ),
        ),
      ],
    );
  }
}

