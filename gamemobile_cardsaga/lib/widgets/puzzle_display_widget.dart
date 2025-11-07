import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/puzzle_image.dart';
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

    final gameService = context.watch<GameService>();
    final collectedPieceIds = gameService.user.puzzlePieces
        .where((p) => p.imageId == widget.puzzleImage.id)
        .map((p) => p.id)
        .toSet();

    final double displayHeight = widget.displayWidth / _imageAspectRatio;

    int maxRow = 0;
    int maxCol = 0;
    if (widget.puzzleImage.pieces.isEmpty) {
      return Container(
          width: widget.displayWidth,
          height: displayHeight,
          color: Colors.grey.shade300,
          child:
              const Center(child: Text("No pieces defined for this puzzle.")));
    }
    for (var piece in widget.puzzleImage.pieces) {
      if (piece.row > maxRow) maxRow = piece.row;
      if (piece.col > maxCol) maxCol = piece.col;
    }
    final numRows = maxRow + 1;
    final numCols = maxCol + 1;

    final pieceDisplayWidth = widget.displayWidth / numCols;
    final pieceDisplayHeight = displayHeight / numRows;

    return Container(
      width: widget.displayWidth,
      height: displayHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                widget.puzzleImage.fullImagePath,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey.shade200),
              ),
            ),
          ),

          ...widget.puzzleImage.pieces.map((piece) {
            final isCollected = collectedPieceIds.contains(piece.id);
            final double displayLeft = piece.col * pieceDisplayWidth;
            final double displayTop = piece.row * pieceDisplayHeight;

            return Positioned(
              left: displayLeft,
              top: displayTop,
              width: pieceDisplayWidth,
              height: pieceDisplayHeight,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey.shade300.withOpacity(0.5), width: 0.5),
                ),
                child: isCollected
                    ? CustomPaint(
                        painter: _SinglePiecePainter(
                          image: _fullUiImage!,
                          srcRect: piece.position,
                        ),
                      )
                    : Container(
                        color: Colors.transparent,
                      ),
              ),
            );
          }).toList(),
          // ------------------------------------
        ],
      ),
    );
  }
}

class _SinglePiecePainter extends CustomPainter {
  final ui.Image image;
  final Rect srcRect;

  _SinglePiecePainter({required this.image, required this.srcRect});

  @override
  void paint(Canvas canvas, Size size) {
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImageRect(image, srcRect, dstRect, paint);
  }

  @override
  bool shouldRepaint(covariant _SinglePiecePainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.srcRect != srcRect;
  }
}
