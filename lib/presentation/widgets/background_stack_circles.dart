import 'package:flutter/material.dart';

class BackgroundTopRightStackCircle extends StatelessWidget {
  const BackgroundTopRightStackCircle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

class BackgroundBottomLeftStackCircle extends StatelessWidget {
  const BackgroundBottomLeftStackCircle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -80,
      left: -80,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
