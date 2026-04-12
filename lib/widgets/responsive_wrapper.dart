import 'package:flutter/material.dart';
import 'unsupported_screen.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return const UnsupportedScreen(
            message: "We don't support the web yet, but will in the future.",
            showAppStoreLink: true,
          );
        }

        final orientation = MediaQuery.of(context).orientation;
        if (orientation == Orientation.landscape) {
          return const UnsupportedScreen(
            message: "We don't support landscape yet, but it's coming.",
            showAppStoreLink: false,
          );
        }

        return child;
      },
    );
  }
}
