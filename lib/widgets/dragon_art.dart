import 'package:flutter/material.dart';

class DragonArt extends StatelessWidget {
  final String? colorName;

  const DragonArt({super.key, this.colorName});

  @override
  Widget build(BuildContext context) {
    final colorStr = colorName?.toLowerCase() ?? 'red';
    
    const validColors = {'pink', 'blue', 'black', 'green', 'silver', 'white', 'red', 'gold', 'rainbow'};
    final assetName = validColors.contains(colorStr) ? colorStr : 'red';

    return Image.asset(
      'assets/images/dragons/sleeping/$assetName.png',
      width: 216,
      height: 200,
      fit: BoxFit.contain,
    );
  }
}
