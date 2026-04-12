import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CampoBuscaWidget extends StatelessWidget {
  final String texto;
  final IconData prefixIcon; //(ex: Icons.search)
  final TextEditingController controller;
  final Function(String)? onChanged;

  const CampoBuscaWidget({
    super.key,
    required this.texto,
    required this.prefixIcon,
    required this.controller,
    this.onChanged, //opcional
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: texto,
        prefixIcon: Icon(prefixIcon, color: Colors.grey),

        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              controller.clear();
              if (onChanged != null) {
                onChanged!('');
              }
            },
          ),
        ),

        hoverColor: Colors.transparent,
        filled: true,
        fillColor: cinzaFundo,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: azulUnifor, width: 2.0),
        ),
      ),
    );
  }
}
