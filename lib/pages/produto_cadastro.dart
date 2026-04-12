import 'package:flutter/material.dart';
import 'package:projeto_enfermagem_desktop/model/produto.dart';
import 'package:projeto_enfermagem_desktop/model/tipo_produto.dart';
import 'package:projeto_enfermagem_desktop/dao/tipo_produto_dao.dart';
import 'package:projeto_enfermagem_desktop/service/gerenciador_estoque_services.dart';
import 'package:projeto_enfermagem_desktop/service/produtos_service.dart';

// IMPORTAÇÕES DE TEMA E WIDGETS CUSTOMIZADOS (Ajuste o caminho se necessário)
import '../theme/theme.dart';
import '../widgets/campo_drop_down_widget.dart';

// Modelo auxiliar para gerenciar o estado de cada linha do formulário
class ItemRowModel {
  TextEditingController nomeController = TextEditingController();
  TextEditingController qtdController = TextEditingController();
  int? idFornecedor;
  int? idTipoProduto;
  Produto? produtoSelecionado;

  // Lógica de cores reativas
  Color get backgroundColor {
    if (produtoSelecionado != null) {
      return Colors.green.shade50;
    }
    if (nomeController.text.isNotEmpty) {
      return Colors.yellow.shade50;
    }
    return Colors.transparent;
  }
}

class ProdutoCadastro extends StatefulWidget {
  final GerenciadorEstoqueServices estoqueServices;
  final ProdutosService produtosService;

  const ProdutoCadastro({
    Key? key,
    required this.estoqueServices,
    required this.produtosService,
  }) : super(key: key);

  @override
  State<ProdutoCadastro> createState() => _ProdutoCadastroState();
}

class _ProdutoCadastroState extends State<ProdutoCadastro> {
  final TextEditingController _nfeController = TextEditingController();
  final TipoProdutoDao _tipoProdutoDao = TipoProdutoDao();

  bool _nfeDuplicada = false;
  bool _nfeVaziaErro = false;

  List<ItemRowModel> _linhasDeItens = [ItemRowModel()];
  List<Produto> _produtosCadastrados = [];
  List<TipoProduto> _tiposProduto = [];

  // Lista de fornecedores (idealmente vinda do banco de dados)
  List<Map<String, dynamic>> _fornecedores = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    try {
      final produtos = await widget.produtosService.buscarTodosOsProdutos();
      final tipos = await _tipoProdutoDao.listarTipos();

      // Simulação ou busca real no SQLite
      final fornecedoresMock = [
        {'id': 1, 'nome': 'Cimed'},
        {'id': 2, 'nome': 'Distrimed'},
        {'id': 3, 'nome': 'MedSupply Ltda'},
      ];

      setState(() {
        _produtosCadastrados = produtos;
        _tiposProduto = tipos;
        _fornecedores = fornecedoresMock;
      });
    } catch (e) {
      print("Erro ao carregar dados iniciais: $e");
    }
  }

  Future<void> _validarNfe(String nfe) async {
    if (nfe.trim().isEmpty) {
      setState(() {
        _nfeVaziaErro = true;
        _nfeDuplicada = false;
      });
      return;
    }

    _nfeVaziaErro = false;
    bool existe = await widget.estoqueServices.checarSeNfeJaExiste(nfe);
    setState(() {
      _nfeDuplicada = existe;
    });
  }

  void _adicionarNovaLinha() {
    setState(() {
      _linhasDeItens.add(ItemRowModel());
    });
  }

  // NOVA FUNÇÃO: Remove a linha baseada no index
  void _removerLinha(int index) {
    setState(() {
      _linhasDeItens.removeAt(index);
    });
  }

  Future<void> _lancarEntrada() async {
    await _validarNfe(_nfeController.text);

    if (_nfeVaziaErro || _nfeDuplicada) {
      _mostrarToast("Corrija o número da NFe antes de lançar.", redAlert);
      return;
    }

    List<ItemLinhaNfe> itensParaSalvar = [];

    for (int i = 0; i < _linhasDeItens.length; i++) {
      var linha = _linhasDeItens[i];

      String nome = linha.nomeController.text.trim();
      double qtd = double.tryParse(linha.qtdController.text) ?? 0.0;

      if (nome.isEmpty || qtd <= 0 || linha.idFornecedor == null) {
        _mostrarToast(
          "Preencha todos os campos obrigatórios da linha ${i + 1}.",
          redAlert,
        );
        return;
      }

      Produto produtoParaSalvar;

      if (linha.produtoSelecionado != null) {
        produtoParaSalvar = linha.produtoSelecionado!;
      } else {
        if (linha.idTipoProduto == null) {
          _mostrarToast(
            "Selecione o Tipo para o novo produto na linha ${i + 1}.",
            redAlert,
          );
          return;
        }

        produtoParaSalvar = Produto(
          nome: nome,
          estoque: 0,
          idFornecedor: linha.idFornecedor!,
          idTipoProduto: linha.idTipoProduto!,
        );
      }

      itensParaSalvar.add(
        ItemLinhaNfe(
          produto: produtoParaSalvar,
          numeroNfe: _nfeController.text.trim(),
          quantidadeEntrada: qtd,
        ),
      );
    }

    try {
      await widget.estoqueServices.salvarLoteDeEntradas(itensParaSalvar);
      _mostrarToast("Lançamento realizado com sucesso!", greenSuccess);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _mostrarToast(e.toString(), redAlert);
    }
  }

  void _mostrarToast(String mensagem, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Visual padronizado dos TextFields alinhado com o CampoDropdownWidget
  InputDecoration _customInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: coolGrey3, fontSize: 14),
      filled: true,
      fillColor: cinzaFundo,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cinzaFundo, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cinzaFundo, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: azulUnifor, width: 2),
      ),
    );
  }

  // Funções de segurança para buscar objetos completos a partir dos IDs nas listas
  Map<String, dynamic>? _getFornecedorSelecionado(int? id) {
    if (id == null) return null;
    try {
      return _fornecedores.firstWhere((f) => f['id'] == id);
    } catch (_) {
      return null;
    }
  }

  TipoProduto? _getTipoProdutoSelecionado(int? id) {
    if (id == null) return null;
    try {
      return _tiposProduto.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Entrada de Notas Fiscais',
          style: textStyleBlackTituloPage,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: cinzaFundo, height: 1.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Canto Direito: Campo NFe
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 300,
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) _validarNfe(_nfeController.text);
                  },
                  child: TextFormField(
                    controller: _nfeController,
                    onChanged: (val) => _validarNfe(val),
                    decoration: _customInputDecoration('Número NFe').copyWith(
                      errorText: _nfeDuplicada
                          ? 'A NFe já existe.'
                          : (_nfeVaziaErro ? 'Informe a NFe.' : null),
                      errorStyle: const TextStyle(
                        color: redAlert,
                        fontWeight: FontWeight.bold,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _nfeDuplicada || _nfeVaziaErro
                              ? redAlert
                              : cinzaFundo,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _nfeDuplicada || _nfeVaziaErro
                              ? redAlert
                              : azulUnifor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Cabeçalho da Tabela
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('Produto / Item', style: textStyleBlackLabel),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Text('Fornecedor', style: textStyleBlackLabel),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Text('Tipo', style: textStyleBlackLabel),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Text('Qtd.', style: textStyleBlackLabel),
                  ),
                  SizedBox(width: 96), // Espaço dos ícones de ação (+ e -)
                ],
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: cinzaFundo, thickness: 2),

            // Lista Dinâmica de Produtos
            Expanded(
              child: ListView.builder(
                itemCount: _linhasDeItens.length,
                itemBuilder: (context, index) {
                  return _buildLinhaProduto(_linhasDeItens[index], index);
                },
              ),
            ),

            // Botão Lançar
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: amareloUnifor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _lancarEntrada,
                child: const Text('Salvar Entrada', style: textStyleBlackLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinhaProduto(ItemRowModel linha, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, top: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: linha.backgroundColor, // Verde claro ou Amarelo claro reativo
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo Nome com AutoComplete
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text vazio apenas para gerar o mesmo espaçamento vertical do CampoDropdownWidget
                const Text('', style: TextStyle(fontSize: 16, height: 1.15)),
                const SizedBox(height: 6),
                Autocomplete<Produto>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Produto>.empty();
                    }
                    return _produtosCadastrados.where(
                      (produto) => produto.nome.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                    );
                  },
                  displayStringForOption: (Produto option) => option.nome,
                  onSelected: (Produto selecao) {
                    setState(() {
                      linha.produtoSelecionado = selecao;
                      linha.nomeController.text = selecao.nome;

                      bool fornecedorExiste = _fornecedores.any(
                        (f) => f['id'] == selecao.idFornecedor,
                      );
                      linha.idFornecedor = fornecedorExiste
                          ? selecao.idFornecedor
                          : null;

                      bool tipoExiste = _tiposProduto.any(
                        (t) => t.id == selecao.idTipoProduto,
                      );
                      linha.idTipoProduto = tipoExiste
                          ? selecao.idTipoProduto
                          : null;
                    });
                  },
                  // CUSTOMIZAÇÃO DA LISTA SUSPENSA DO AUTOCOMPLETE
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 250,
                            maxWidth: 350,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, i) {
                              final produto = options.elementAt(i);
                              return InkWell(
                                onTap: () => onSelected(produto),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: cinzaFundo),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        produto.nome,
                                        style: textStyleBlackLabel.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Estoque atual: ${produto.estoque.toInt()}',
                                        style: textStyleSubTituloHeader,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  fieldViewBuilder:
                      (
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        linha.nomeController = textEditingController;
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: _customInputDecoration(
                            'Digite o nome...',
                          ),
                          onChanged: (texto) {
                            setState(() {
                              if (linha.produtoSelecionado != null &&
                                  texto != linha.produtoSelecionado!.nome) {
                                linha.produtoSelecionado = null;
                                linha.idFornecedor = null;
                                linha.idTipoProduto = null;
                              }
                            });
                          },
                        );
                      },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Campo Fornecedor (Custom Widget)
          Expanded(
            flex: 2,
            child: CampoDropdownWidget<Map<String, dynamic>>(
              label:
                  '', // Deixamos vazio pois já temos o cabeçalho no topo da tabela
              hintText: 'Selecione',
              items: _fornecedores,
              value: _getFornecedorSelecionado(linha.idFornecedor),
              getLabel: (fornecedor) => fornecedor['nome'],
              onSelected: (selecionado) {
                setState(() {
                  linha.idFornecedor = selecionado['id'];
                });
              },
            ),
          ),
          const SizedBox(width: 12),

          // Campo Tipo Produto (Custom Widget)
          Expanded(
            flex: 2,
            child: CampoDropdownWidget<TipoProduto>(
              label: '',
              hintText: 'Selecione',
              items: _tiposProduto,
              value: _getTipoProdutoSelecionado(linha.idTipoProduto),
              getLabel: (tipo) => tipo.descricao,
              onSelected: (selecionado) {
                setState(() {
                  linha.idTipoProduto = selecionado.id;
                });
              },
            ),
          ),
          const SizedBox(width: 12),

          // Campo Estoque (Quantidade)
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Espaçador para alinhar com o CampoDropdownWidget
                const Text('', style: TextStyle(fontSize: 16, height: 1.15)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: linha.qtdController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _customInputDecoration('0'),
                ),
              ],
            ),
          ),

          // Botões de Ação (+ e -)
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 26.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Só renderiza o botão de remover se houver mais de uma linha na tela
                if (_linhasDeItens.length > 1)
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                      size: 36,
                    ),
                    onPressed: () => _removerLinha(index),
                    tooltip: 'Remover este produto',
                  ),

                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: Color(0xFF0038A8),
                    size: 36,
                  ), // Substituí 'azulUnifor' por uma cor hex temporária caso o const dê erro, mas você pode voltar para sua variável.
                  onPressed: _adicionarNovaLinha,
                  tooltip: 'Adicionar outro produto',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
