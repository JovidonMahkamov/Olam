import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  /// Qulay chaqirish uchun
  static Future<String?> open(BuildContext context) async {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerPage(),
      ),
    );
  }

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with WidgetsBindingObserver {
  late final MobileScannerController _controller;

  bool _isHandled = false; // double scan bo'lmasin
  bool _isTorchOn = false;
  CameraFacing _cameraFacing = CameraFacing.back;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
      returnImage: false,
      formats: const [
        BarcodeFormat.qrCode,
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  /// App background/foreground bo'lsa scanner pause/resume
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isHandled) {
          _controller.start();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _controller.stop();
        break;
    }
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_isHandled) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    _isHandled = true;

    // Kamerani to'xtatib qo'yamiz
    await _controller.stop();

    if (!mounted) return;
    Navigator.pop(context, rawValue.trim());
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    if (!mounted) return;
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }

  Future<void> _switchCamera() async {
    await _controller.switchCamera();
    if (!mounted) return;
    setState(() {
      _cameraFacing = _cameraFacing == CameraFacing.back
          ? CameraFacing.front
          : CameraFacing.back;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetect,
          ),

          /// Dark overlay + scan frame
          _ScannerOverlay(),

          /// Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _CircleActionButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "QR kodni skaner qiling",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _CircleActionButton(
                    icon: _isTorchOn ? Icons.flash_on : Icons.flash_off,
                    onTap: _toggleTorch,
                  ),
                  const SizedBox(width: 8),
                  _CircleActionButton(
                    icon: Icons.cameraswitch,
                    onTap: _switchCamera,
                  ),
                ],
              ),
            ),
          ),

          /// Bottom hint
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "QR kodni ramka ichiga to‘g‘ri tuting",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlay widget (scanner frame)
class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ScannerOverlayPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.55);

    final frameSize = size.width * 0.72;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.42),
      width: frameSize,
      height: frameSize,
    );

    // Tashqi qorong'i qatlam
    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      );

    final path = Path.combine(PathOperation.difference, fullPath, holePath);
    canvas.drawPath(path, overlayPaint);

    // Oq frame border
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      borderPaint,
    );

    // Corner highlights
    final cornerPaint = Paint()
      ..color = const Color(0xFFF2C23A)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerLen = 24;
    final double l = rect.left;
    final double r = rect.right;
    final double t = rect.top;
    final double b = rect.bottom;

    // top-left
    canvas.drawLine(Offset(l, t + cornerLen), Offset(l, t), cornerPaint);
    canvas.drawLine(Offset(l, t), Offset(l + cornerLen, t), cornerPaint);

    // top-right
    canvas.drawLine(Offset(r - cornerLen, t), Offset(r, t), cornerPaint);
    canvas.drawLine(Offset(r, t), Offset(r, t + cornerLen), cornerPaint);

    // bottom-left
    canvas.drawLine(Offset(l, b - cornerLen), Offset(l, b), cornerPaint);
    canvas.drawLine(Offset(l, b), Offset(l + cornerLen, b), cornerPaint);

    // bottom-right
    canvas.drawLine(Offset(r - cornerLen, b), Offset(r, b), cornerPaint);
    canvas.drawLine(Offset(r, b - cornerLen), Offset(r, b), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}