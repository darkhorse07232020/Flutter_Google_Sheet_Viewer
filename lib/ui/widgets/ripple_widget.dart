import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RippleWidget extends StatelessWidget {
  final Color color;
  final Color highlightColor;
  final Color splashColor;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final BorderRadius borderRadius;
  final double radius;
  final Widget child;

  RippleWidget({
    this.color = Colors.blueAccent,
    this.splashColor,
    this.highlightColor,
    this.radius,
    this.borderRadius = BorderRadius.zero,
    this.onTap,
    this.onLongPress,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          splashColor: splashColor ?? color.withOpacity(0.3),
          highlightColor: highlightColor ?? color.withOpacity(0.2),
          borderRadius: radius != null ? BorderRadius.circular(radius) : borderRadius,
          onTap: onTap,
          onLongPress: onLongPress,
          child: child,
        ),
      ),
    );
  }
}
