import 'package:flutter/material.dart';

class Campo_busca_produto extends StatefulWidget {
  const Campo_busca_produto({super.key});

  @override
  State<Campo_busca_produto> createState() => _Campo_busca_produtoState();
}

class _Campo_busca_produtoState extends State<Campo_busca_produto> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Buscar produto...",
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blueGrey),
        ),
      ),
    );
  }
}
