import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DragonArt extends StatelessWidget {
  final String? colorName;

  const DragonArt({super.key, this.colorName});

  static const Map<String, Color> _dragonColorMap = {
    'red': Color(0xFFCC3333),
    'blue': Color(0xFF3388CC),
    'green': Color(0xFF408000),
    'gold': Color(0xFFD4AF37),
    'pink': Color(0xFFCC6699),
    'purple': Color(0xFF8844AA),
    'teal': Color(0xFF008080),
  };

  @override
  Widget build(BuildContext context) {
    final baseColor = _dragonColorMap[colorName?.toLowerCase()] ?? const Color(0xFF6B4D57);
    final darkColor = _darken(baseColor, 0.25);
    final lightColor = _lighten(baseColor, 0.25);

    // Convert colors to hex for SVG string interpolation
    final baseHex = '#${(baseColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final darkHex = '#${(darkColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final lightHex = '#${(lightColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

    final svgString = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="-20 0 240 200">
  <g id="standing-dragon">
    <!-- Tail (behind body) -->
    <path d="M 120 160 Q 180 180 170 120 Q 160 140 130 140 Z" fill="$darkHex" />
    <path d="M 165 130 L 175 125 L 170 140 Z" fill="$lightHex" /> <!-- Tail spike -->
    
    <!-- Wings behind -->
    <!-- Left Bat Wing -->
    <path d="M 80 90 L -10 10 Q 20 40 5 60 Q 25 80 20 110 Q 50 120 65 110 Z" fill="$darkHex" />

    <!-- Right Bat Wing -->
    <path d="M 120 90 L 210 10 Q 180 40 195 60 Q 175 80 180 110 Q 150 120 135 110 Z" fill="$darkHex" />

    <!-- Body -->
    <rect x="65" y="80" width="70" height="95" rx="35" fill="$baseHex" />
    
    <!-- Belly (lighter patch) -->
    <rect x="75" y="90" width="50" height="75" rx="25" fill="$lightHex" />

    <!-- Feet -->
    <circle cx="70" cy="175" r="16" fill="$darkHex" />
    <circle cx="130" cy="175" r="16" fill="$darkHex" />
    <!-- Claws -->
    <circle cx="62" cy="182" r="3" fill="#ffffff" />
    <circle cx="70" cy="184" r="3" fill="#ffffff" />
    <circle cx="78" cy="182" r="3" fill="#ffffff" />
    <circle cx="122" cy="182" r="3" fill="#ffffff" />
    <circle cx="130" cy="184" r="3" fill="#ffffff" />
    <circle cx="138" cy="182" r="3" fill="#ffffff" />

    <!-- Arms/Hands -->
    <circle cx="60" cy="130" r="14" fill="$darkHex" />
    <circle cx="140" cy="130" r="14" fill="$darkHex" />
    <circle cx="55" cy="135" r="2.5" fill="#ffffff" />
    <circle cx="60" cy="137" r="2.5" fill="#ffffff" />
    <circle cx="65" cy="135" r="2.5" fill="#ffffff" />
    <circle cx="135" cy="135" r="2.5" fill="#ffffff" />
    <circle cx="140" cy="137" r="2.5" fill="#ffffff" />
    <circle cx="145" cy="135" r="2.5" fill="#ffffff" />

    <!-- Head -->
    <circle cx="100" cy="65" r="40" fill="$baseHex" />

    <!-- Ears / Horns -->
    <path d="M 70 40 L 30 10 Q 50 30 65 55 Z" fill="#E8DCC4" />
    <path d="M 130 40 L 170 10 Q 150 30 135 55 Z" fill="#E8DCC4" />

    <!-- Head Spikes -->
    <path d="M 90 28 L 110 28 L 100 5 Z" fill="$lightHex" />

    <!-- Snout -->
    <ellipse cx="100" cy="85" rx="30" ry="18" fill="$lightHex" />
    
    <!-- Nostrils -->
    <circle cx="88" cy="85" r="4" fill="$darkHex" />
    <circle cx="112" cy="85" r="4" fill="$darkHex" />

    <!-- Eyes (Squinted, pointy ends) -->
    <path d="M 72 55 Q 82 48 92 55 Q 82 62 72 55 Z" fill="#ffffff" />
    <path d="M 108 55 Q 118 48 128 55 Q 118 62 108 55 Z" fill="#ffffff" />
    <circle cx="82" cy="55" r="2.5" fill="#000000" />
    <circle cx="118" cy="55" r="2.5" fill="#000000" />
    <!-- Sparkles -->
    <circle cx="81" cy="54.5" r="1" fill="#ffffff" />
    <circle cx="117" cy="54.5" r="1" fill="#ffffff" />
  </g>
</svg>
''';

    return SizedBox(
      width: 216,
      height: 200,
      child: SvgPicture.string(svgString),
    );
  }

  Color _darken(Color c, double amount) {
    final f = 1 - amount;
    return Color.fromARGB(
      (c.a * 255.0).round().clamp(0, 255),
      (c.r * 255.0 * f).round().clamp(0, 255),
      (c.g * 255.0 * f).round().clamp(0, 255),
      (c.b * 255.0 * f).round().clamp(0, 255),
    );
  }

  Color _lighten(Color c, double amount) {
    return Color.fromARGB(
      (c.a * 255.0).round().clamp(0, 255),
      (c.r * 255.0 + (1 - c.r) * 255.0 * amount).round().clamp(0, 255),
      (c.g * 255.0 + (1 - c.g) * 255.0 * amount).round().clamp(0, 255),
      (c.b * 255.0 + (1 - c.b) * 255.0 * amount).round().clamp(0, 255),
    );
  }
}
