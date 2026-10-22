import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Camera QR scanning behind an interface, so the door screen runs (and is
/// tested) without a camera, and a device without one falls back to typed
/// codes.
// ignore: one_member_abstracts
abstract interface class CodeScannerBackend {
  /// The live preview; calls [onCode] for every decoded QR value and
  /// [onUnavailable] when the camera can not be used (denied, missing).
  Widget preview({
    required ValueChanged<String> onCode,
    required VoidCallback onUnavailable,
  });
}

/// mobile_scanner (CameraX / ML Kit on Android, AVFoundation on iOS).
class MobileScannerBackend implements CodeScannerBackend {
  const MobileScannerBackend();

  @override
  Widget preview({
    required ValueChanged<String> onCode,
    required VoidCallback onUnavailable,
  }) => _MobileScannerView(onCode: onCode, onUnavailable: onUnavailable);
}

class _MobileScannerView extends StatefulWidget {
  const _MobileScannerView({required this.onCode, required this.onUnavailable});
  final ValueChanged<String> onCode;
  final VoidCallback onUnavailable;

  @override
  State<_MobileScannerView> createState() => _MobileScannerViewState();
}

class _MobileScannerViewState extends State<_MobileScannerView> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _reported = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MobileScanner(
    controller: _controller,
    onDetect: (capture) {
      for (final b in capture.barcodes) {
        final v = b.rawValue;
        if (v != null && v.isNotEmpty) {
          widget.onCode(v);
          return;
        }
      }
    },
    errorBuilder: (context, error) {
      if (!_reported) {
        _reported = true;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.onUnavailable(),
        );
      }
      return const ColoredBox(color: Colors.black);
    },
  );
}

final codeScannerProvider = Provider<CodeScannerBackend>(
  (ref) => const MobileScannerBackend(),
);
