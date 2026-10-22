import 'package:eventra/features/profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

/// Circle with the user's initials on their chosen color.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    required this.name,
    required this.color,
    super.key,
    this.size = 96,
    this.borderWidth = 3,
  });

  final String? name;
  final Color color;
  final double size;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final text = name == null ? null : initialsOf(name!);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: borderWidth > 0
            ? Border.all(color: Colors.white, width: borderWidth)
            : null,
      ),
      alignment: Alignment.center,
      child: text == null
          ? Icon(Icons.person, color: Colors.white, size: size * 0.55)
          : Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.36,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
