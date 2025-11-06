import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/puzzle_image.dart';
import '../widgets/puzzle_display_widget.dart';
import '../providers/lang_provider.dart';
import '../utils/constants.dart';
import '../widgets/top_status_bar.dart';

class PuzzleScreen extends StatefulWidget {
  final PuzzleImage puzzleImage;

  const PuzzleScreen({Key? key, required this.puzzleImage}) : super(key: key);

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final t = lang.locale.languageCode == 'en' ? Strings.en : Strings.vi;

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 10.0 * 2;
    final displayWidth = screenWidth - horizontalPadding;

    final collectedCount = widget.puzzleImage.collectedCount;
    final totalCount = widget.puzzleImage.totalCount;
    final isCompleted = widget.puzzleImage.isCompleted;

    return Scaffold(
      appBar: TopStatusBar(
        title: '${t['puzzle_gallery_title'] ?? 'Puzzle'}',
        showBack: true,
        showShopButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: PuzzleDisplayWidget(
                  puzzleImage: widget.puzzleImage,
                  displayWidth: displayWidth,
                ),
              ),
            ),
            // --------------------------------------------------------

            const SizedBox(height: 20),

            // --- Phần Tiến độ ---
            if (isCompleted) // Hiển thị thông báo nếu đã hoàn thành
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  t['puzzle_complete'] ?? 'Puzzle Complete!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            Text(
              '$collectedCount / $totalCount',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: totalCount > 0 ? collectedCount / totalCount : 0,
                  backgroundColor: Colors.grey.shade300,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                  minHeight: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isCompleted) const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
