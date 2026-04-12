import 'package:flutter/material.dart';
import 'package:projeto_enfermagem_desktop/model/produto.dart';

class ProdutosInfo extends StatelessWidget {
  final Produto produto;

  const ProdutosInfo({super.key, required this.produto});

  @override
  Widget build(BuildContext context) {
    // 1. Lógicas de tradução temporárias
    String nomeFornecedor = 'Desconhecido';
    if (produto.idFornecedor == 1) nomeFornecedor = 'Cimed';
    if (produto.idFornecedor == 2) nomeFornecedor = 'Distrimed';

    String nomeUnidade = 'Comprimido';

    // 2. Trazendo a SUA lógica de estoque para a tela de detalhes
    final bool alertaEstoque = produto.estoqueBaixo(
      produto.idTipoProduto,
      produto.estoque,
    );

    // 3. Pegando a largura total da tela do Desktop
    final double larguraTela = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalhes do Produto',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        // O Align garante que o card fique na esquerda e não tente centralizar
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            // Aqui definimos a largura para exatamente 50% da tela!
            width: larguraTela * 0.5,
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Faz a altura do card abraçar o conteúdo
              children: [
                const Text(
                  'Informações',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(child: _buildInfoItem('Nome', produto.nome)),
                    Expanded(
                      child: _buildInfoItem('Fornecedor', nomeFornecedor),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(child: _buildInfoItem('Unidade', nomeUnidade)),
                    Expanded(
                      // Passamos a variável do alerta para o widget desenhar a cor
                      child: _buildEstoqueItem(
                        'Estoque Atual',
                        produto.estoque.toInt().toString(),
                        alertaEstoque, // Enviando o bool para a função abaixo!
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Adicionamos o parâmetro `alertaEstoque` para a cor ser dinâmica
  Widget _buildEstoqueItem(String label, String value, bool alertaEstoque) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            // A mágica da reatividade da cor acontece aqui!
            color: alertaEstoque
                ? const Color(0xFFDC3545)
                : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
