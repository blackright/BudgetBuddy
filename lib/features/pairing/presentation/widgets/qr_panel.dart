import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// A white, padded QR code panel shared by the pairing screens (US7).
///
/// A white background is required so the code stays scannable in dark themes.
class QrPanel extends StatelessWidget {
  const QrPanel({super.key, required this.data, this.size = 240});

  /// The exact string to encode.
  final String data;

  /// The rendered square size of the code.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
      ),
    );
  }
}
