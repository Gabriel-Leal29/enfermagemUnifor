import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme.dart';

class CampoTextoWidget extends StatefulWidget{
  const CampoTextoWidget({
    required this.label,
    required this.controller,
    this.obrigatorio = false,
     this.inputFormatter,
    this.validator,
    this.hintText,
    this.focusNode,
    this.minLines,
    this.maxLines,
    this.sufixoIcon,
    this.readOnly,
    this.onTap,
    super.key
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool obrigatorio;
  final List<TextInputFormatter>? inputFormatter;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final int? minLines;
  final int? maxLines;
  final Icon? sufixoIcon;
  final bool? readOnly;
  final void Function()? onTap;

  @override
  State<StatefulWidget> createState() => _CampoTextoWidget();

}

class _CampoTextoWidget extends State<CampoTextoWidget>{
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: textStyleBlackLabel),
        const SizedBox(height: 6),
        TextFormField(
          readOnly: widget.readOnly ?? false,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          focusNode: widget.focusNode,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.controller,
          inputFormatters: widget.inputFormatter,
          onTap: widget.onTap,
          decoration: InputDecoration(
            suffixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 12.0),
              child: widget.sufixoIcon
            ),
            hoverColor: Colors.transparent,
            hintText: widget.hintText,
            filled: true,
            fillColor: cinzaFundo,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: cinzaFundo,
                  width: 1.5,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: azulUnifor,
                  width: 2,
                ),
              ),
          ),
            validator: (value) {
              if (widget.obrigatorio && ( value == null || value == "" || value.trim().isEmpty)) {
                return "Campo obrigatório";
              }

              // vai fazer a validação
              if (widget.validator != null) {
                return widget.validator!(value);
              }

              return null;
            }
        ),
      ],
    )
  );
}