import 'package:flutter/material.dart';

class botao_novo_produto extends StatefulWidget {
  const botao_novo_produto({super.key});

  @override
  State<botao_novo_produto> createState() => _botao_novo_produtoState();
}

class _botao_novo_produtoState extends State<botao_novo_produto> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.add, color: Colors.black87, size: 20),
      label: const Text(
        "Novo Produto",
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFC107), // Amarelo do botão
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }
}
