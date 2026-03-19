import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'content/toast_content.dart';

enum ToastType { success, error, warning, info }

void showToast(
    BuildContext context, {
      required String message,
      ToastType type = ToastType.info,
    }) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  // ... (mantenha o switch de cores/ícones igual ao anterior)
  Color color = type == ToastType.success ? greenSuccess : (type == ToastType.error ? redAlert : (type == ToastType.warning ? amberWarning : Colors.blue));
  IconData icon = type == ToastType.success ? Icons.check_circle : (type == ToastType.error ? Icons.error : (type == ToastType.warning ? Icons.warning : Icons.info));

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 50,
       right: 30,
      child: Center(
        child: ToastContent(
          message: message,
          icon: icon,
          color: color,
          onDismiss: () {
            if (overlayEntry.mounted) {
              overlayEntry.remove();
            }
          },
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
}