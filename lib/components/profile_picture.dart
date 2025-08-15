import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String? dp;
  final String name;
  final double radius;

  const ProfilePicture(
      {super.key, this.dp, required this.name, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    if (dp == null || dp!.isEmpty) {
      return FallbackAvatarNameWidget(
        name: name,
        radius: radius,
      );
    }
    return CircleAvatar(
        radius: radius,
        foregroundImage: FileImage(File(dp!)),
        backgroundImage: CachedNetworkImageProvider(
          dp!,
        ));
  }
}

class FallbackAvatarNameWidget extends StatelessWidget {
  final String name;
  final double radius;

  const FallbackAvatarNameWidget(
      {super.key, required this.name, required this.radius});

  Color _generateBackgroundColor(String name) {
    int hash = name.hashCode;
    int colorIndex = hash % Colors.primaries.length;
    return Colors.primaries[colorIndex];
  }

  Color _getContrastingTextColor(Color backgroundColor) {
    double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _generateBackgroundColor(name);
    final textColor = _getContrastingTextColor(backgroundColor);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: 2 * radius,
        height: 2 * radius,
        color: backgroundColor.withOpacity(0.8),
        child: Center(
          child: Text(
            name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              fontSize: radius * 1.1,
              color: textColor,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }
}
