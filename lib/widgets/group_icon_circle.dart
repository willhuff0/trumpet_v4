import 'package:flutter/material.dart';
import 'package:trumpet/database/db.dart';
import 'package:trumpet/firebase_image/firebase_image.dart';

class GroupIconCircle extends StatelessWidget {
  final TGroup group;
  final double radius;

  const GroupIconCircle({super.key, required this.group, this.radius = 24.0});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: group.hasIcon ? FirebaseImage(group.iconRefUrl) : null,
      minRadius: radius,
      maxRadius: radius,
      child: group.hasIcon
          ? null
          : Text(
              group.initials,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: radius - 6.0,
              ),
            ),
    );
  }
}
