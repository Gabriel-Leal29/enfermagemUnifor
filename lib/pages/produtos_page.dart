import 'package:flutter/material.dart';
import 'package:projeto_enfermagem_desktop/theme/campo_busca_produto.dart';
import 'package:projeto_enfermagem_desktop/theme/botao_novo_produto.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {


  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Produtos",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              botao_novo_produto(), //configuração botão de adicionar produto
            ],
          ),

          const SizedBox(height: 24),
          Campo_busca_produto(), //configuração barra de pesquisa de produto
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
