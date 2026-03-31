import 'package:flutter/material.dart';

class NamaaLogo extends StatelessWidget {
  final double width;
  final double padding;
  final double elevation;
  final double borderRadius;

  const NamaaLogo({
    super.key,
    this.width = 80,
    this.padding = 12,
    this.elevation = 6,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: Colors.transparent,
      shadowColor: elevation > 0 ? Colors.black.withAlpha(50) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Image.asset(
          'assets/images/logo_namaa.png',
          width: width,
          height: width, // Ensure it's square
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
