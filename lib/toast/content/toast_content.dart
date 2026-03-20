import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class ToastContent extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onDismiss;

  const ToastContent({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
    required this.onDismiss,
  });

  @override
  State<ToastContent> createState() => _ToastContentState();
}

class _ToastContentState extends State<ToastContent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // remove o tast
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDismiss();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1)),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(widget.icon, color: widget.color),
                    const SizedBox(width: 10),
                    Expanded(child: Text(widget.message, style: textStyleBlackToast)),
                  ],
                ),
              ),

              // barra de progresso
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: 1 - _controller.value,
                    backgroundColor: widget.color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    minHeight: 4,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}