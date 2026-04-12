import 'package:flutter/material.dart';

enum _AppButtonType { elevated, elevatedIcon, outlined, text }

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final Widget? icon;
  final Widget? label;
  final ButtonStyle? style;
  final _AppButtonType _type;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  })  : _type = _AppButtonType.elevated,
        icon = null,
        label = null;

  const AppButton.icon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.style,
  })  : _type = _AppButtonType.elevatedIcon,
        child = null;

  const AppButton.outlined({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  })  : _type = _AppButtonType.outlined,
        icon = null,
        label = null;

  const AppButton.text({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  })  : _type = _AppButtonType.text,
        icon = null,
        label = null;

  @override
  Widget build(BuildContext context) {
    Widget button;
    switch (_type) {
      case _AppButtonType.elevated:
        button = ElevatedButton(
          onPressed: onPressed,
          style: style,
          child: child!,
        );
        break;
      case _AppButtonType.elevatedIcon:
        button = ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon!,
          label: label!,
          style: style,
        );
        break;
      case _AppButtonType.outlined:
        button = OutlinedButton(
          onPressed: onPressed,
          style: style,
          child: child!,
        );
        break;
      case _AppButtonType.text:
        button = TextButton(
          onPressed: onPressed,
          style: style,
          child: child!,
        );
        break;
    }

    // Applying Center ensure it works within Columns with stretch or rows 
    // while keeping its width constrained instead of being stretched infinitely.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400.0),
        child: button,
      ),
    );
  }
}
