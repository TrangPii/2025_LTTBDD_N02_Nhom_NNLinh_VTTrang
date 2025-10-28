import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../services/game_service.dart';
import '../widgets/level_node.dart';
import '../providers/lang_provider.dart';
import '../utils/constants.dart';
import '../widgets/top_status_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameService>();
    final lang = context.watch<LangProvider>();
    final t = lang.locale.languageCode == 'en' ? Strings.en : Strings.vi;

    final screenWidth = MediaQuery.of(context).size.width;
    const nodeSize = 64.0;
    const verticalGap = 120.0;
    final totalLevels = gs.levels.length;
    final contentHeight = math.max(600.0, totalLevels * verticalGap + 200.0);

    final leftA = 24.0;
    final leftB = screenWidth - nodeSize - 24.0;

    return Scaffold(
      appBar: TopStatusBar(title: t['map_title']!, showShopButton: true),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFEAF4), Color(0xFFFFD6EC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              height: contentHeight,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(screenWidth, contentHeight),
                    painter: _PathPainter(
                      totalLevels: totalLevels,
                      verticalGap: verticalGap,
                    ),
                  ),
                  ...List.generate(totalLevels, (i) {
                    final level = gs.levels[i];
                    final left = (i % 2 == 0) ? leftA : leftB;
                    final top = i * verticalGap + 40.0;

                    return Positioned(
                      left: left,
                      top: top,
                      width: nodeSize,
                      height: nodeSize + 30,
                      child: Column(
                        children: [
                          SizedBox(
                            width: nodeSize,
                            height: nodeSize,
                            child: LevelNode(level: level, onTap: () {}),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (starIndex) {
                              final filled = level.stars > starIndex;
                              return Icon(
                                filled ? Icons.star : Icons.star_border,
                                size: 16,
                                color: filled
                                    ? Colors.amber
                                    : Colors.grey.shade400,
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  }),
                  Positioned(
                    left: (screenWidth - 140) / 2,
                    top: 8,
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map, color: Colors.pink),
                          const SizedBox(width: 8),
                          Text(
                            t['map_title']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final int totalLevels;
  final double verticalGap;
  _PathPainter({required this.totalLevels, required this.verticalGap});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pinkAccent.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerX = size.width / 2;
    path.moveTo(centerX, 20);

    for (int i = 0; i < totalLevels; i++) {
      final yStart = i * verticalGap + 20;
      final yMid = yStart + verticalGap / 2;
      final yEnd = yStart + verticalGap;

      final controlX = (i % 2 == 0) ? 60.0 : (size.width - 60.0);
      path.quadraticBezierTo(controlX, yMid, centerX, yEnd);
    }

    final shadow = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, shadow);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
