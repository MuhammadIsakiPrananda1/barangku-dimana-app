import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;
  double _currentZoom = 0.0;

  @override
  void initState() {
    super.initState();
    _initController();
    
    // Laser animation: moves up and down every 2 seconds
    _laserController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  void _initController() {
    controller = MobileScannerController(
      autoStart: true,
      formats: isBarcodeMode
          ? [BarcodeFormat.code128, BarcodeFormat.ean13, BarcodeFormat.ean8]
          : [BarcodeFormat.qrCode],
    );
  }

  Future<void> _toggleMode() async {
    // 1. Properly stop and dispose the current controller before starting a new one
    // This prevents the "camera already in use" or "white screen" issue
    try {
      await controller.stop();
      await controller.dispose();
      // Berikan jeda sangat singkat agar hardware kamera benar-benar siap
      await Future.delayed(const Duration(milliseconds: 50));
    } catch (e) {
      // Ignore errors during disposal
    }

    if (mounted) {
      setState(() {
        isBarcodeMode = !isBarcodeMode;
        _initController();
      });
    }
  }

  @override
  void dispose() {
    _laserController.dispose();
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
              // Using a key forces the widget to completely remount when the mode changes,
              // which is the most reliable way to reset the camera state.
              key: ValueKey(isBarcodeMode),
              controller: controller,
              errorBuilder: (context, error) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white, size: 40),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal membuka kamera',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        error.errorCode.toString(),
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
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

          // 4. Scanning Box Frame, Laser & Anim
          Center(
            child: Transform.translate(
              offset: Offset(0, verticalOffset),
              child: SizedBox(
                width: boxWidth,
                height: boxHeight,
                child: Stack(
                  children: [
                    // Animated Laser
                    AnimatedBuilder(
                      animation: _laserAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: ScannerLaserPainter(
                            progress: _laserAnimation.value,
                            color: AppTheme.emerald,
                          ),
                          size: Size(boxWidth, boxHeight),
                        );
                      },
                    ),
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
                // Quick Controls Row (Moved from side)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildQuickControlButton(
                      icon: Icons.flash_on_rounded,
                      onPressed: () => controller.toggleTorch(),
                      label: 'Senter',
                    ),
                    const SizedBox(width: 40),
                    _buildQuickControlButton(
                      icon: Icons.flip_camera_ios_rounded,
                      onPressed: () => controller.switchCamera(),
                      label: 'Putar',
                    ),
                    const SizedBox(width: 40),
                    _buildQuickControlButton(
                      icon: _currentZoom == 0.0 ? Icons.zoom_in_rounded : Icons.zoom_out_rounded,
                      onPressed: () {
                        setState(() {
                          _currentZoom = _currentZoom == 0.0 ? 0.5 : 0.0;
                          controller.setZoomScale(_currentZoom);
                        });
                      },
                      label: _currentZoom == 0.0 ? '1x' : '2x',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
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

  Widget _buildQuickControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String label,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            onPressed();
            HapticFeedback.mediumImpact();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class ScannerLaserPainter extends CustomPainter {
  final double progress;
  final Color color;

  ScannerLaserPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withValues(alpha: 0),
          color,
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, size.height * progress, size.width, 2))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw the laser line
    final y = size.height * progress;
    
    // Add a subtle glow/shadow to the laser
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawRect(
      Rect.fromLTWH(10, y - 2, size.width - 20, 4),
      glowPaint,
    );

    canvas.drawLine(
      Offset(10, y),
      Offset(size.width - 10, y),
      paint..color = color.withValues(alpha: 1.0),
    );
  }

  @override
  bool shouldRepaint(covariant ScannerLaserPainter oldDelegate) => true;
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
