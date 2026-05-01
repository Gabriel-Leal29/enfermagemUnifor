import 'package:flutter/material.dart';

import '../theme/theme.dart';

class ButtonAmareloWidget extends StatefulWidget{
  const ButtonAmareloWidget({
    required this.texto,
    required this.onPressed,
    this.isCancelamento = false,
    this.icone,
    super.key
  });

  final String texto;
  final VoidCallback onPressed;
  final IconData? icone;
  final bool isCancelamento;

  @override
  State<StatefulWidget> createState() => _ButtonAmareloWidgetState();
}

class _ButtonAmareloWidgetState extends State<ButtonAmareloWidget>{
  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          enabledMouseCursor: MouseCursor.uncontrolled,
          backgroundColor: widget.isCancelamento ? cinzaFundo : amareloUnifor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
            ),
          elevation: 5,
        ).copyWith(
          mouseCursor: WidgetStateProperty.resolveWith<MouseCursor?>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) return SystemMouseCursors.basic;
              return SystemMouseCursors.click;
            },
          ),
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