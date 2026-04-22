import 'package:flutter/material.dart';
import 'package:projeto_enfermagem_desktop/pages/produtos_info.dart';
import '../theme/theme.dart';
import '../widgets/button_amarelo_widget.dart';
import '../widgets/campo_busca_widget.dart';
import '../widgets/campo_texto_widget.dart';
import '../toast/show_toast.dart';
import '../widgets/campo_drop_down_widget.dart';
import 'package:projeto_enfermagem_desktop/dao/produto_dao.dart';
import 'package:projeto_enfermagem_desktop/model/produto.dart';
import '../service/produtos_service.dart';
import '../pages/produto_cadastro.dart';
import '../dao/gerenciador_estoque_dao.dart';
import '../service/gerenciador_estoque_services.dart';
import '../model/gerenciador_estoque.dart';
import '../dao/tipo_produto_dao.dart';
import '../service/fornecedor_service.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  final TextEditingController _buscaController = TextEditingController();

  late final ProdutosService _produtosService;
  late final FornecedorService _fornecedorService;
  late final TipoProdutoDao _tipoProdutoDao;
  late final GerenciadorEstoqueServices _estoqueServices;

  List<Produto> todosOsProdutos = [];
  List<Produto> produtosFiltrados = [];

  Map<int, String> fornecedoresMap = {};
  Map<int, String> tiposProdutoMap = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final produtoDao = ProdutoDao();
    _produtosService = ProdutosService(produtoDao);
    _fornecedorService = FornecedorService();
    _tipoProdutoDao = TipoProdutoDao();
    _estoqueServices = GerenciadorEstoqueServices(
      GerenciadorEstoqueDao(),
      produtoDao,
      _produtosService,
    );

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
      final fornecedoresDoBanco = await _fornecedorService.buscarFornecedores();
      final tiposDoBanco = await _tipoProdutoDao.listarTipos();

      final Map<int, String> mapF = {
        for (var f in fornecedoresDoBanco)
          if (f.id != null) f.id!: f.nome,
      };

      final Map<int, String> mapT = {
        for (var t in tiposDoBanco)
          if (t.id != null) t.id!: t.descricao,
      };

      setState(() {
        todosOsProdutos = dadosDoBanco;
        produtosFiltrados = dadosDoBanco;
        fornecedoresMap = mapF;
        tiposProdutoMap = mapT;
        isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar dados: $e");
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

  void _mostrarModalEdicao(BuildContext context, Produto produto) {
    final formKey = GlobalKey<FormState>();

    TextEditingController nomeController = TextEditingController(
      text: produto.nome,
    );
    TextEditingController estoqueController = TextEditingController(
      text: produto.estoque.toInt().toString(),
    );

    int idFornecedorSelecionado = produto.idFornecedor;
    int idTipoProdutoSelecionado = produto.idTipoProduto;

    List<int> listaFornecedores = fornecedoresMap.keys.toList();
    List<int> listaTipos = tiposProdutoMap.keys.toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Editar Produto',
                style: textStyleBlackTituloPage,
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CampoTextoWidget(
                          label: 'Nome',
                          controller: nomeController,
                          obrigatorio: true,
                        ),
                        const SizedBox(height: 8),

                        CampoTextoWidget(
                          label: 'Estoque',
                          controller: estoqueController,
                          obrigatorio: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty)
                              return "Campo obrigatório";
                            if (double.tryParse(value.replaceAll(',', '.')) ==
                                null)
                              return "Número inválido";
                            if (double.parse(value.replaceAll(',', '.')) < 0)
                              return "Não pode ser negativo";
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        CampoDropdownWidget<int>(
                          label: 'Unidade',
                          items: listaTipos,
                          value: idTipoProdutoSelecionado,
                          getLabel: (id) =>
                              tiposProdutoMap[id] ?? 'Desconhecido',
                          onSelected: (valorSelecionado) {
                            setStateModal(() {
                              idTipoProdutoSelecionado = valorSelecionado;
                            });
                          },
                        ),
                        const SizedBox(height: 8),

                        CampoDropdownWidget<int>(
                          label: 'Fornecedor',
                          items: listaFornecedores,
                          value: idFornecedorSelecionado,
                          getLabel: (id) =>
                              fornecedoresMap[id] ?? 'Desconhecido',
                          onSelected: (valorSelecionado) {
                            setStateModal(() {
                              idFornecedorSelecionado = valorSelecionado;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                  ),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      String novoNome = nomeController.text.trim();
                      double novoEstoque = double.parse(
                        estoqueController.text.replaceAll(',', '.'),
                      );

                      bool produtoDuplicado = todosOsProdutos.any(
                        (p) =>
                            p.id != produto.id &&
                            p.nome.toLowerCase() == novoNome.toLowerCase() &&
                            p.idFornecedor == idFornecedorSelecionado &&
                            p.idTipoProduto == idTipoProdutoSelecionado,
                      );

                      if (produtoDuplicado) {
                        showToast(
                          dialogContext,
                          message:
                              'Não é possível salvar: Já existe outro produto com as mesmas características!',
                          type: ToastType.error,
                        );
                        return;
                      }

                      try {
                        if (novoEstoque != produto.estoque) {
                          String situacao = await _estoqueServices.verSituacao(
                            produto,
                            novoEstoque,
                          );

                          double diferenca = (novoEstoque - produto.estoque)
                              .abs();

                          GerenciadorEstoque historicoAjuste =
                              GerenciadorEstoque(
                                data: DateTime.now(),
                                numeroNfe: '000',
                                quantidade: diferenca,
                                idProduto: produto.id!,
                                situacao: situacao,
                              );

                          await GerenciadorEstoqueDao()
                              .inserirGerenciadorEstoque(historicoAjuste);
                        }

                        Produto produtoAtualizado = Produto(
                          id: produto.id,
                          nome: novoNome,
                          estoque: novoEstoque,
                          idFornecedor: idFornecedorSelecionado,
                          idTipoProduto: idTipoProdutoSelecionado,
                        );

                        await _produtosService.editarProduto(produtoAtualizado);

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);

                          showToast(
                            context,
                            message: 'Produto atualizado com sucesso!',
                            type: ToastType.success,
                          );
                        }
                        setState(() => isLoading = true);
                        await _carregarDados();
                      } catch (e) {
                        if (dialogContext.mounted) {
                          showToast(
                            dialogContext,
                            message: 'Erro ao atualizar: $e',
                            type: ToastType.error,
                          );
                        }
                      }
                    }
                  },
                  child: const Text(
                    'Salvar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
                  final atualizou = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProdutoCadastro(
                        produtosService: _produtosService,
                        estoqueServices: _estoqueServices,
                      ),
                    ),
                  );

                  if (atualizou == true) {
                    setState(() => isLoading = true);
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
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Ações',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey.shade700,
                              ),
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

                      final String nomeFornecedor =
                          fornecedoresMap[produto.idFornecedor] ??
                          'Desconhecido';
                      final String nomeTipo =
                          tiposProdutoMap[produto.idTipoProduto] ??
                          'Desconhecido';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProdutosInfo(
                                produto: produto,
                                nomeFornecedor: nomeFornecedor,
                                nomeTipo: nomeTipo,
                              ),
                            ),
                          );
                        },
                        hoverColor: Colors.blueGrey.shade50,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 6.0,
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
                                  nomeTipo,
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

                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.amber,
                                    ),
                                    tooltip: '',
                                    onPressed: () {
                                      _mostrarModalEdicao(context, produto);
                                    },
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
