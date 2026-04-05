import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SleepingDragonWindow extends StatelessWidget {
  final String? colorName;

  const SleepingDragonWindow({super.key, this.colorName});

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

    final baseHex = '#${(baseColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final darkHex = '#${(darkColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final lightHex = '#${(lightColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

    final now = DateTime.now();
    final isDay = now.hour >= 6 && now.hour < 20;
    
    final skyColor = isDay ? '#87CEEB' : '#0B1D3A';
    final starOpacity = isDay ? '0' : '1';
    final sunOpacity = isDay ? '1' : '0';
    final moonOpacity = isDay ? '0' : '1';

    final svgString = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 240">
  <!-- Sky Background -->
  <rect x="20" y="20" width="200" height="180" fill="\$skyColor" />

  <!-- Sun -->
  <circle cx="180" cy="60" r="24" fill="#FFD700" opacity="\$sunOpacity" />
  
  <!-- Moon (crescent) -->
  <path d="M 180 40 A 20 20 0 1 0 200 65 A 16 16 0 1 1 180 40 Z" fill="#F4F6F0" opacity="\$moonOpacity" />

  <!-- Stars -->
  <g fill="#FFFFFF" opacity="\$starOpacity">
    <circle cx="50" cy="50" r="1.5" />
    <circle cx="90" cy="30" r="1.5" />
    <circle cx="120" cy="75" r="2" />
    <circle cx="35" cy="115" r="2" />
    <circle cx="195" cy="100" r="1.5" />
    <circle cx="150" cy="45" r="1" />
  </g>

  <!-- Window Frame -->
  <!-- Outer frame -->
  <rect x="10" y="10" width="220" height="200" fill="none" stroke="#2D211B" stroke-width="20" />
  <!-- Inner mullions -->
  <rect x="115" y="20" width="10" height="180" fill="#2D211B" />
  <rect x="20" y="105" width="200" height="10" fill="#2D211B" />

  <!-- Window Sill -->
  <path d="M 0 200 L 240 200 L 230 230 L 10 230 Z" fill="#423329" />
  <rect x="0" y="230" width="240" height="10" fill="#251b14" />

  <!-- Sleeping Dragon on the Sill -->
  <g id="sleeping-dragon">
    <!-- Tail behind -->
    <path d="M 170 175 Q 210 175 200 145 Q 180 135 160 155 Z" fill="\$darkHex" />
    <path d="M 195 150 L 205 140 L 200 160 Z" fill="\$lightHex" /> <!-- Tail spike -->
    
    <!-- Wing Folded (shielding) -->
    <path d="M 100 120 Q 130 90 155 135 Q 120 175 80 155 Z" fill="\$darkHex" />

    <!-- Body lying down -->
    <!-- Base body on sill (y=200 is bottom) -->
    <rect x="70" y="135" width="105" height="55" rx="27.5" fill="\$baseHex" />
    
    <!-- Belly (lighter patch) -->
    <rect x="80" y="150" width="85" height="35" rx="17.5" fill="\$lightHex" />

    <!-- Back detail: Folded wings over body -->
    <path d="M 85 140 Q 125 115 165 140 Z" fill="\$darkHex" />

    <!-- Feet -->
    <circle cx="95" cy="185" r="14" fill="\$darkHex" />
    <circle cx="155" cy="185" r="14" fill="\$darkHex" />
    <!-- Claws -->
    <circle cx="87" cy="193" r="2.5" fill="#ffffff" />
    <circle cx="95" cy="195" r="2.5" fill="#ffffff" />
    <circle cx="103" cy="193" r="2.5" fill="#ffffff" />
    <circle cx="147" cy="193" r="2.5" fill="#ffffff" />
    <circle cx="155" cy="195" r="2.5" fill="#ffffff" />
    <circle cx="163" cy="193" r="2.5" fill="#ffffff" />

    <!-- Front Arms/Hands tucked under head -->
    <circle cx="55" cy="180" r="13" fill="\$darkHex" />
    <!-- Claws -->
    <circle cx="47" cy="186" r="2.5" fill="#ffffff" />
    <circle cx="55" cy="188" r="2.5" fill="#ffffff" />
    <circle cx="63" cy="186" r="2.5" fill="#ffffff" />

    <!-- Head Resting -->
    <!-- Head base -->
    <circle cx="68" cy="155" r="35" fill="\$baseHex" />

    <!-- Ears / Horns pointed back/down slightly -->
    <!-- Left horn -->
    <path d="M 45 135 L 15 120 Q 35 130 45 145 Z" fill="#E8DCC4" />
    <!-- Right horn -->
    <path d="M 85 135 L 115 120 Q 95 130 85 145 Z" fill="#E8DCC4" />

    <!-- Head Spikes lying flat -->
    <path d="M 68 120 L 88 110 L 83 130 Z" fill="\$lightHex" />

    <!-- Snout resting on paw -->
    <ellipse cx="48" cy="165" rx="25" ry="16" fill="\$lightHex" />
    
    <!-- Nostrils -->
    <circle cx="33" cy="165" r="3" fill="\$darkHex" />
    <circle cx="58" cy="165" r="3" fill="\$darkHex" />

    <!-- Closed Eyes -->
    <path d="M 48 145 Q 58 152 68 145" fill="none" stroke="\$darkHex" stroke-width="2.5" stroke-linecap="round" />
    
    <path d="M 78 145 Q 85 152 92 145" fill="none" stroke="\$darkHex" stroke-width="2.5" stroke-linecap="round" />

    <!-- Zzz -->
    <!-- small z -->
    <path d="M 25 110 L 35 110 L 25 120 L 35 120" fill="none" stroke="#FFFFFF" stroke-width="2" stroke-linejoin="round" />
    <!-- medium z -->
    <path d="M 10 85 L 25 85 L 10 100 L 25 100" fill="none" stroke="#FFFFFF" stroke-width="2.5" stroke-linejoin="round" />
    <!-- large Z -->
    <path d="M -15 50 L 10 50 L -15 75 L 10 75" fill="none" stroke="#FFFFFF" stroke-width="3" stroke-linejoin="round" />
  </g>
</svg>
''';

    return SizedBox(
      width: 240,
      height: 240,
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
