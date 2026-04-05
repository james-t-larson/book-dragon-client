import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessyBookStack extends StatelessWidget {
  const MessyBookStack({super.key});

  @override
  Widget build(BuildContext context) {
    // Instead of random, use fixed geometry to satisfy "consistent stack"
    // Books are drawn as colored rounded rectangles slightly rotated.
    // Made very wide instead of tall to give the dragon a large resting plane.
    return SizedBox(
      width: 340,
      height: 90,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Row 1 (Bottom foundation)
          Positioned(
            bottom: 0,
            left: 0,
            child: Transform.rotate(
              angle: -0.02,
              child: _buildBook(const Color(0xFF4A3424), 200, 32, 'The Ancient King'),
            ),
          ),
          Positioned(
            bottom: -5,
            right: 0,
            child: Transform.rotate(
              angle: 0.04,
              child: _buildBook(const Color(0xFF2B3A4A), 180, 28, 'Dragon Lore'),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 140,
            child: Transform.rotate(
              angle: -0.01,
              child: _buildBook(const Color(0xFF6B2B36), 160, 30, 'Spells & Hexes'),
            ),
          ),

          // Row 2 (Middle layer)
          Positioned(
            bottom: 25,
            left: 20,
            child: Transform.rotate(
              angle: 0.05,
              child: _buildBook(const Color(0xFF1B4D53), 150, 24, 'Alchemy Vol. II'),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 30,
            child: Transform.rotate(
              angle: -0.08,
              child: _buildBook(const Color(0xFF5A4634), 160, 26, 'Compendium'),
            ),
          ),
          Positioned(
            bottom: 28,
            left: 100,
            child: Transform.rotate(
              angle: -0.05,
              child: _buildBook(const Color(0xFF332244), 190, 28, 'Lost Prophecies'),
            ),
          ),

          // Row 3 (Top accents)
          Positioned(
            bottom: 48,
            right: 60,
            child: Transform.rotate(
              angle: 0.12,
              child: _buildBook(const Color(0xFF884433), 130, 22, 'Grimoire'),
            ),
          ),
          Positioned(
            bottom: 53,
            left: 50,
            child: Transform.rotate(
              angle: -0.1,
              child: _buildBook(const Color(0xFF225544), 140, 20, 'Tome of Fire'),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 130,
            child: Transform.rotate(
              angle: 0.02,
              child: _buildBook(const Color(0xFF4B3A2A), 150, 25, 'Elder Scrolls'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBook(Color color, double width, double height, String title) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(2, 4),
            blurRadius: 6,
          )
        ],
        border: Border.all(color: Colors.black38, width: 1.5),
      ),
      child: Row(
        children: [
          // Book spine details
          Container(
            width: 14,
            decoration: const BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                bottomLeft: Radius.circular(4),
              ),
              border: Border(right: BorderSide(color: Colors.black45, width: 1)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.medievalSharp(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: const [Shadow(color: Colors.black87, blurRadius: 2)],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Right texture/pages
          Container(
            width: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFF0EAD6), // Page paper color
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(height: 1, color: Colors.brown.withValues(alpha: 0.2)),
                Container(height: 1, color: Colors.brown.withValues(alpha: 0.2)),
                Container(height: 1, color: Colors.brown.withValues(alpha: 0.2)),
                Container(height: 1, color: Colors.brown.withValues(alpha: 0.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
