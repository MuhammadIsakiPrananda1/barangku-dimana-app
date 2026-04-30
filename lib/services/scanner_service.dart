import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class ScannerService {
  static Future<String?> scanBarcode(BuildContext context) async {
    String? result;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ScannerWidget(),
    ).then((val) {
      if (val is String) result = val;
    });
    return result;
  }
}

class ScannerWidget extends StatefulWidget {
  const ScannerWidget({Key? key}) : super(key: key);

  @override
  State<ScannerWidget> createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget> with SingleTickerProviderStateMixin {
  bool isBarcodeMode = false;
  late MobileScannerController controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    controller = MobileScannerController(
      formats: isBarcodeMode
          ? [BarcodeFormat.code128, BarcodeFormat.ean13, BarcodeFormat.ean8]
          : [BarcodeFormat.qrCode],
    );
  }

  void _toggleMode() {
    setState(() {
      isBarcodeMode = !isBarcodeMode;
      controller.dispose();
      _initController();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    // Dynamic dimensions based on mode
    final boxWidth = isBarcodeMode ? 320.0 : 250.0;
    final boxHeight = isBarcodeMode ? 160.0 : 250.0;
    
    // Calculate vertical offset to avoid bottom controls
    // We want the box to be slightly above the center
    final verticalOffset = -60.0; 

    return Container(
      height: size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // 1. Camera Preview
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? code = barcodes.first.rawValue;
                  if (code != null) {
                    HapticFeedback.heavyImpact();
                    Navigator.pop(context, code);
                  }
                }
              },
            ),
          ),

          // 2. Darkened Overlay with Dynamic Hole
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlayPainter(
                boxWidth: boxWidth,
                boxHeight: boxHeight,
                verticalOffset: verticalOffset,
              ),
            ),
          ),

          // 3. Close Button (Header Style)
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: const Text(
                      'Scan Barang',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Scanning Box Frame & Laser
          Center(
            child: Transform.translate(
              offset: Offset(0, verticalOffset),
              child: SizedBox(
                width: boxWidth,
                height: boxHeight,
                child: Stack(
                  children: [
                    // Corner accents
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ScannerFramePainter(color: AppTheme.emerald),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. Bottom Controls (Well-spaced)
          Positioned(
            bottom: 30 + bottomPadding,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeSelector(),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        isBarcodeMode ? 'Arahkan pada kode batang barang' : 'Arahkan pada kode QR barang',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(false, Icons.qr_code_2_rounded, 'QR Code'),
          _buildModeButton(true, Icons.barcode_reader, 'Barcode'),
        ],
      ),
    );
  }

  Widget _buildModeButton(bool mode, IconData icon, String label) {
    final isSelected = isBarcodeMode == mode;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          _toggleMode();
          HapticFeedback.lightImpact();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.emerald : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white60, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double boxWidth;
  final double boxHeight;
  final double verticalOffset;

  ScannerOverlayPainter({
    required this.boxWidth,
    required this.boxHeight,
    required this.verticalOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final center = Offset(size.width / 2, (size.height / 2) + verticalOffset);
    final innerRect = Rect.fromCenter(
      center: center,
      width: boxWidth,
      height: boxHeight,
    );
    
    final innerPath = Path()..addRRect(RRect.fromRectAndRadius(innerRect, const Radius.circular(20)));

    final combinedPath = Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(combinedPath, paint);
    
    // Add subtle border glow to the hole
    final glowPaint = Paint()
      ..color = AppTheme.emerald.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(RRect.fromRectAndRadius(innerRect, const Radius.circular(20)), glowPaint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.boxWidth != boxWidth || oldDelegate.boxHeight != boxHeight;
  }
}

class ScannerFramePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;

  ScannerFramePainter({
    required this.color,
    this.strokeWidth = 3.5,
    this.cornerLength = 25.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;
    const radius = 20.0; // Same as the hole radius

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, radius)
        ..arcToPoint(const Offset(radius, 0), radius: const Radius.circular(radius))
        ..lineTo(cornerLength, 0),
      paint,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(width - cornerLength, 0)
        ..lineTo(width - radius, 0)
        ..arcToPoint(Offset(width, radius), radius: const Radius.circular(radius))
        ..lineTo(width, cornerLength),
      paint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(width, height - cornerLength)
        ..lineTo(width, height - radius)
        ..arcToPoint(Offset(width - radius, height), radius: const Radius.circular(radius))
        ..lineTo(width - cornerLength, height),
      paint,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(cornerLength, height)
        ..lineTo(radius, height)
        ..arcToPoint(Offset(0, height - radius), radius: const Radius.circular(radius))
        ..lineTo(0, height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
