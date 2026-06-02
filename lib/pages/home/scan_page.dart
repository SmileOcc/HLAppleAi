import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_constants.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _controller;
  bool _hasResult = false;
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasResult) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;
    _hasResult = true;
    _showResult(barcode!.rawValue!);
  }

  void _showResult(String value) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('扫描结果'),
        content: Text(value),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _hasResult = false;
            },
            child: const Text('继续扫描'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('扫一扫'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_outlined),
            onPressed: () => _controller?.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android_outlined),
            onPressed: () => _controller?.switchCamera(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final scanSize = min(w * 0.7, 300.0);
          final top = (h - scanSize) / 2 - 50;
          final left = (w - scanSize) / 2;
          final scanRect = Rect.fromLTWH(left, top, scanSize, scanSize);

          return Stack(
            children: [
              MobileScanner(controller: _controller, onDetect: _onDetect),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ScanOverlayPainter(
                      scanRect: scanRect,
                      lineProgress: _animation.value,
                    ),
                    size: Size(w, h),
                  );
                },
              ),
              Positioned(
                top: scanRect.bottom + 20,
                left: 0,
                width: w,
                child: const Text(
                  '将二维码/条形码放入框内',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  final Rect scanRect;
  final double lineProgress;

  _ScanOverlayPainter({required this.scanRect, required this.lineProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16)));
    canvas.drawPath(path, overlayPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(16)),
      borderPaint,
    );

    const cornerLen = 24.0;
    const cornerW = 3.5;
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerW
      ..strokeCap = StrokeCap.round;
    final r = scanRect;

    canvas.drawLine(r.topLeft, Offset(r.left + cornerLen, r.top), cornerPaint);
    canvas.drawLine(r.topLeft, Offset(r.left, r.top + cornerLen), cornerPaint);

    canvas.drawLine(
      r.topRight,
      Offset(r.right - cornerLen, r.top),
      cornerPaint,
    );
    canvas.drawLine(
      r.topRight,
      Offset(r.right, r.top + cornerLen),
      cornerPaint,
    );

    canvas.drawLine(
      r.bottomLeft,
      Offset(r.left + cornerLen, r.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      r.bottomLeft,
      Offset(r.left, r.bottom - cornerLen),
      cornerPaint,
    );

    canvas.drawLine(
      r.bottomRight,
      Offset(r.right - cornerLen, r.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      r.bottomRight,
      Offset(r.right, r.bottom - cornerLen),
      cornerPaint,
    );

    final lineY = scanRect.top + 8 + lineProgress * (scanRect.height - 16);
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.35)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawLine(
      Offset(scanRect.left + 12, lineY),
      Offset(scanRect.right - 12, lineY),
      glowPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left + 12, lineY),
      Offset(scanRect.right - 12, lineY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter oldDelegate) =>
      scanRect != oldDelegate.scanRect ||
      lineProgress != oldDelegate.lineProgress;
}
