import 'package:flutter/material.dart';
import 'package:projeto_enfermagem_desktop/pages/produtos_info.dart';
import '../theme/theme.dart';
import '../widgets/button_amarelo_widget.dart';
import '../widgets/campo_busca_widget.dart';

import 'package:projeto_enfermagem_desktop/dao/produto_dao.dart';
import 'package:projeto_enfermagem_desktop/model/produto.dart';
import '../service/produtos_service.dart';
import '../pages/produto_cadastro.dart';
import '../dao/gerenciador_estoque_dao.dart';
import '../service/gerenciador_estoque_services.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  final TextEditingController _buscaController = TextEditingController();
  late final ProdutosService _produtosService;

  List<Produto> todosOsProdutos = [];
  List<Produto> produtosFiltrados = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inicializa o serviço injetando o DAO
    _produtosService = ProdutosService(ProdutoDao());
    _carregarDados();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      final dadosDoBanco = await _produtosService.buscarTodosOsProdutos();

      setState(() {
        todosOsProdutos = dadosDoBanco;
        produtosFiltrados = dadosDoBanco;
        isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar produtos: $e");
      setState(() => isLoading = false);
    }
  }

  void _filtrarLista(String textoDigitado) {
    setState(() {
      if (textoDigitado.isEmpty) {
        produtosFiltrados = todosOsProdutos;
      } else {
        produtosFiltrados = todosOsProdutos
            .where(
              (produto) => produto.nome.toLowerCase().contains(
                textoDigitado.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

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
              const Text("Produtos", style: textStyleBlackTituloPage),
              ButtonAmareloWidget(
                texto: 'Novo Produto',
                onPressed: () async {
                  // O 'await' fica AQUI, esperando a tela fechar
                  final atualizou = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProdutoCadastro(
                        // Passando as dependências obrigatórias
                        produtosService: _produtosService,
                        estoqueServices: GerenciadorEstoqueServices(
                          GerenciadorEstoqueDao(),
                          ProdutoDao(), // Como você injetou no initState
                          _produtosService,
                        ),
                      ),
                    ),
                  );

                  // A tela ProdutoCadastro retorna 'true' quando salva com sucesso.
                  // Assim, só fazemos a consulta no banco se realmente houver novos dados.
                  if (atualizou == true) {
                    await _carregarDados();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          CampoBuscaWidget(
            texto: "Pesquisar Produto",
            prefixIcon: Icons.search_rounded,
            controller: _buscaController,
            onChanged: _filtrarLista,
          ),

          const SizedBox(height: 24),

          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (produtosFiltrados.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Center(child: Text("Nenhum produto encontrado.")),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Nome',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Unidade',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Fornecedor',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Estoque',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: produtosFiltrados.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final produto = produtosFiltrados[index];
                      final bool alertaEstoque = produto.estoqueBaixo(
                        produto.idTipoProduto,
                        produto.estoque,
                      );

                      // Lógica temporária para traduzir o ID no nome do Fornecedor
                      String nomeFornecedor = 'Desconhecido';
                      if (produto.idFornecedor == 1) nomeFornecedor = 'Cimed';
                      if (produto.idFornecedor == 2)
                        nomeFornecedor = 'Distrimed';

                      return InkWell(
                        onTap: () {
                          // Abre a nova tela passando o produto que foi clicado nesta linha
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProdutosInfo(produto: produto),
                            ),
                          );
                        },
                        hoverColor: Colors.blueGrey.shade50,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  produto.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Und.', // Temporário
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ),

                              Expanded(
                                flex: 2,
                                child: Text(
                                  nomeFornecedor,
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ),

                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: alertaEstoque
                                          ? const Color(0xFFDC3545)
                                          : const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      produto.estoque.toInt().toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
