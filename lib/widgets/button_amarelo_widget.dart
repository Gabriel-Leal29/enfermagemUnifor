import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

class ButtonAmareloWidget extends StatefulWidget{
  const ButtonAmareloWidget({
    required this.texto,
    required this.onPressed,
    this.icone,
    super.key
  });

  final String texto;
  final VoidCallback onPressed;
  final IconData? icone;

  @override
  State<StatefulWidget> createState() => _ButtonAmareloWidgetState();
}

class _ButtonAmareloWidgetState extends State<ButtonAmareloWidget>{
  @override
  Widget build(BuildContext context) => ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: amareloUnifor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
          ),
        elevation: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icone != null) ...[
            IconTheme(
              data: const IconThemeData(size: 18),
              child: Icon(widget.icone!),
            ),
            const SizedBox(width: 8),
          ],
          Text(widget.texto, style: textStyleBlackLabel),
        ],
      )
  );
}