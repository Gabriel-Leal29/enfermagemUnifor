import 'package:flutter/material.dart';
import 'package:projeto_enfermagem_desktop/model/produto.dart';
import 'package:projeto_enfermagem_desktop/model/tipo_produto.dart';
import 'package:projeto_enfermagem_desktop/dao/tipo_produto_dao.dart';
import 'package:projeto_enfermagem_desktop/service/gerenciador_estoque_services.dart';
import 'package:projeto_enfermagem_desktop/service/produtos_service.dart';
import 'package:projeto_enfermagem_desktop/model/fornecedor.dart';
import 'package:projeto_enfermagem_desktop/service/fornecedor_service.dart';
import '../toast/show_toast.dart';
import '../theme/theme.dart';
import '../widgets/campo_drop_down_widget.dart';

class ItemRowModel {
  TextEditingController nomeController = TextEditingController();
  TextEditingController qtdController = TextEditingController();
  int? idFornecedor;
  int? idTipoProduto;
  Produto? produtoSelecionado;

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
  final FornecedorService _fornecedorService = FornecedorService();

  bool _nfeDuplicada = false;
  bool _nfeVaziaErro = false;

  List<ItemRowModel> _linhasDeItens = [ItemRowModel()];
  List<Produto> _produtosCadastrados = [];
  List<TipoProduto> _tiposProduto = [];

  List<Fornecedor> _fornecedores = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    try {
      final produtos = await widget.produtosService.buscarTodosOsProdutos();
      final tipos = await _tipoProdutoDao.listarTipos();
      final fornecedores = await _fornecedorService.buscarFornecedores();

      setState(() {
        _produtosCadastrados = produtos;
        _tiposProduto = tipos;
        _fornecedores = fornecedores;
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

  void _removerLinha(int index) {
    setState(() {
      _linhasDeItens.removeAt(index);
    });
  }

  void _verificarSeProdutoExiste(ItemRowModel linha) {
    String nomeDigitado = linha.nomeController.text.trim().toLowerCase();

    if (nomeDigitado.isEmpty ||
        linha.idFornecedor == null ||
        linha.idTipoProduto == null) {
      linha.produtoSelecionado = null;
      return;
    }

    try {
      Produto match = _produtosCadastrados.firstWhere(
        (p) =>
            p.nome.toLowerCase() == nomeDigitado &&
            p.idFornecedor == linha.idFornecedor &&
            p.idTipoProduto == linha.idTipoProduto,
      );

      bool jaEstaNaLista = _linhasDeItens.any(
        (l) => l != linha && l.produtoSelecionado?.id == match.id,
      );
      if (jaEstaNaLista) {
        _mostrarToast(
          "O produto '${match.nome}' já está em outra linha!",
          ToastType.error,
        );
        linha.produtoSelecionado = null;
        linha.idFornecedor = null;
        return;
      }

      linha.produtoSelecionado = match;
    } catch (e) {
      linha.produtoSelecionado = null;
    }
  }

  Future<void> _lancarEntrada() async {
    await _validarNfe(_nfeController.text);

    if (_nfeVaziaErro || _nfeDuplicada) {
      _mostrarToast(
        "Corrija o número da NFe antes de lançar.",
        ToastType.error,
      );
      return;
    }

    List<ItemLinhaNfe> itensParaSalvar = [];
    Set<String> produtosNestaNota = {};

    for (int i = 0; i < _linhasDeItens.length; i++) {
      var linha = _linhasDeItens[i];

      String nome = linha.nomeController.text.trim();
      double qtd = double.tryParse(linha.qtdController.text) ?? 0.0;

      if (nome.isEmpty ||
          qtd <= 0 ||
          linha.idFornecedor == null ||
          linha.idTipoProduto == null) {
        _mostrarToast(
          "Preencha todos os campos obrigatórios da linha ${i + 1}.",
          ToastType.error,
        );
        return;
      }

      String dnaDoProduto =
          "${nome.toLowerCase()}_${linha.idFornecedor}_${linha.idTipoProduto}";

      if (produtosNestaNota.contains(dnaDoProduto)) {
        _mostrarToast(
          "Erro: O produto '$nome' está repetido. Agrupe as quantidades em uma única linha!",
          ToastType.error,
        );
        return;
      }
      produtosNestaNota.add(dnaDoProduto);

      Produto produtoParaSalvar;

      if (linha.produtoSelecionado != null) {
        produtoParaSalvar = linha.produtoSelecionado!;
      } else {
        try {
          Produto matchOculto = _produtosCadastrados.firstWhere(
            (p) =>
                p.nome.toLowerCase() == nome.toLowerCase() &&
                p.idFornecedor == linha.idFornecedor &&
                p.idTipoProduto == linha.idTipoProduto,
          );
          produtoParaSalvar = matchOculto;
        } catch (e) {
          produtoParaSalvar = Produto(
            nome: nome,
            estoque: 0,
            idFornecedor: linha.idFornecedor!,
            idTipoProduto: linha.idTipoProduto!,
          );
        }
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
      _mostrarToast("Lançamento realizado com sucesso!", ToastType.success);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _mostrarToast(e.toString(), ToastType.error);
    }
  }

  void _mostrarToast(String mensagem, ToastType tipo) {
    showToast(context, message: mensagem, type: tipo);
  }

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

  Fornecedor? _getFornecedorSelecionado(int? id) {
    if (id == null) return null;
    try {
      return _fornecedores.firstWhere((f) => f.id == id);
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
                  SizedBox(width: 96),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: cinzaFundo, thickness: 2),

            Expanded(
              child: ListView.builder(
                itemCount: _linhasDeItens.length,
                itemBuilder: (context, index) {
                  return _buildLinhaProduto(_linhasDeItens[index], index);
                },
              ),
            ),

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
      key: ObjectKey(linha),
      margin: const EdgeInsets.only(bottom: 12, top: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: linha.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('', style: TextStyle(fontSize: 16, height: 1.15)),
                const SizedBox(height: 6),
                Autocomplete<Produto>(
                  initialValue: TextEditingValue(
                    text: linha.nomeController.text,
                  ),
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
                      bool jaEstaNaLista = _linhasDeItens.any(
                        (l) =>
                            l != linha &&
                            l.produtoSelecionado?.id == selecao.id,
                      );
                      if (jaEstaNaLista) {
                        _mostrarToast(
                          "O produto '${selecao.nome}' já está em outra linha!",
                          ToastType.error,
                        );
                        linha.nomeController.clear();
                        return;
                      }

                      linha.nomeController.text = selecao.nome;

                      bool fornecedorExiste = _fornecedores.any(
                        (f) => f.id == selecao.idFornecedor,
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

                      _verificarSeProdutoExiste(linha);
                    });
                  },
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
                              _verificarSeProdutoExiste(linha);
                            });
                          },
                        );
                      },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            flex: 2,
            child: CampoDropdownWidget<Fornecedor>(
              label: '',
              hintText: 'Selecione',
              items: _fornecedores,
              value: _getFornecedorSelecionado(linha.idFornecedor),
              getLabel: (fornecedor) => fornecedor.nome,
              onSelected: (selecionado) {
                setState(() {
                  linha.idFornecedor = selecionado.id;
                  _verificarSeProdutoExiste(linha);
                });
              },
            ),
          ),
          const SizedBox(width: 12),

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
                  _verificarSeProdutoExiste(linha);
                });
              },
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 26.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  ),
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
