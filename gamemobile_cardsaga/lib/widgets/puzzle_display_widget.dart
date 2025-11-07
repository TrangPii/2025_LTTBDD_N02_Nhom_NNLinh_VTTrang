import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/puzzle_image.dart';
import '../models/puzzle_piece.dart';
import '../services/game_service.dart';

class PuzzleDisplayWidget extends StatefulWidget {
  final PuzzleImage puzzleImage;
  final double displayWidth;

  const PuzzleDisplayWidget({
    super.key,
    required this.puzzleImage,
    required this.displayWidth,
  });

  @override
  State<PuzzleDisplayWidget> createState() => _PuzzleDisplayWidgetState();
}

class _PuzzleDisplayWidgetState extends State<PuzzleDisplayWidget> {
  ui.Image? _fullUiImage;
  bool _isLoading = true;
  double _imageAspectRatio = 1.0;

  @override
  void initState() {
    super.initState();
    _loadFullImage();
  }

  @override
  void didUpdateWidget(covariant PuzzleDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.puzzleImage.id != oldWidget.puzzleImage.id) {
      _isLoading = true;
      _fullUiImage = null;
      _loadFullImage();
    }
  }

  Future<void> _loadFullImage() async {
    try {
      final data = await rootBundle.load(widget.puzzleImage.fullImagePath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _fullUiImage = frame.image;
          _imageAspectRatio =
              _fullUiImage!.width.toDouble() / _fullUiImage!.height.toDouble();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint("Error loading full puzzle image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.displayWidth,
        height: widget.displayWidth / _imageAspectRatio,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_fullUiImage == null) {
      return SizedBox(
        width: widget.displayWidth,
        height: widget.displayWidth / _imageAspectRatio,
        child: Container(
          color: Colors.red.shade100,
          child: const Center(
            child: Icon(Icons.error_outline, color: Colors.red, size: 40),
          ),
        ),
      );
    }

    // Lấy danh sách các mảnh đã thu thập
    final gameService = context.watch<GameService>();
    final collectedPieces = gameService.user.puzzlePieces
        .where((p) => p.imageId == widget.puzzleImage.id)
        .toList();

    return Container(
      width: widget.displayWidth,
      height: widget.displayWidth / _imageAspectRatio,
      child: CustomPaint(
        painter: _PuzzlePainter(
          image: _fullUiImage!,
          allPieces: widget.puzzleImage.pieces,
          collectedPieces: collectedPieces,
        ),
      ),
    );
  }
}

// Painter xử lý tất cả logic vẽ
class _PuzzlePainter extends CustomPainter {
  final ui.Image image;
  final List<PuzzlePiece> allPieces;
  final List<PuzzlePiece> collectedPieces;

  _PuzzlePainter({
    required this.image,
    required this.allPieces,
    required this.collectedPieces,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.high;

    final Rect imageRect =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final Rect displayRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // nền mờ cho tranh ghép
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.75);

    canvas.drawImageRect(image, imageRect, displayRect, paint);
    canvas.drawRect(displayRect, bgPaint);

    final double scaleX = size.width / image.width.toDouble();
    final double scaleY = size.height / image.height.toDouble();

    for (final piece in collectedPieces) {
      final Rect srcRect = piece.position;

      final Rect dstRect = Rect.fromLTWH(
        srcRect.left * scaleX,
        srcRect.top * scaleY,
        srcRect.width * scaleX,
        srcRect.height * scaleY,
      );

      // Vẽ mảnh ghép
      canvas.drawImageRect(image, srcRect, dstRect, paint);
    }

    // Vẽ đường lưới mờ phân mảnh
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (final piece in allPieces) {
      final Rect srcRect = piece.position;
      final Rect dstRect = Rect.fromLTWH(
        srcRect.left * scaleX,
        srcRect.top * scaleY,
        srcRect.width * scaleX,
        srcRect.height * scaleY,
      );
      canvas.drawRect(dstRect, gridPaint); // Vẽ ô lưới
    }
  }

  @override
  bool shouldRepaint(covariant _PuzzlePainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.collectedPieces.length != collectedPieces.length;
  }
}
