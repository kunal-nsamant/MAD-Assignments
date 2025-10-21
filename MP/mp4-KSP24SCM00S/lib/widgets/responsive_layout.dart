import 'package:flutter/material.dart';

// widget that figures out how many columns to show based on screen width
class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context, int columns) builder;

  const ResponsiveLayout({Key? key, required this.builder}) : super(key: key);

  // basic logic to determine how many cards to show in a row
  int _calculateColumns(double width) {
    if (width >= 1200) return 5;
    if (width >= 992) return 4;
    if (width >= 768) return 3;
    if (width >= 480) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = _calculateColumns(screenWidth);

    return builder(context, columns);
  }
}
