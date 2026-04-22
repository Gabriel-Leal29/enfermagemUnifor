import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../widgets/campo_busca_widget.dart';
import '../widgets/campo_drop_down_widget.dart';
import '../dao/gerenciador_estoque_dao.dart';
import '../model/gerenciador_estoque.dart';
import '../dao/produto_dao.dart';
import '../model/produto.dart';

class MovimentacoesPage extends StatefulWidget {
  const MovimentacoesPage({super.key});

  @override
  State<MovimentacoesPage> createState() => _MovimentacoesPageState();
}

class _MovimentacoesPageState extends State<MovimentacoesPage> {
  final TextEditingController _buscaController = TextEditingController();

  late final GerenciadorEstoqueDao _estoqueDao;
  late final ProdutoDao _produtoDao;

  List<GerenciadorEstoque> todosOsLancamentos = [];
  List<GerenciadorEstoque> lancamentosFiltrados = [];
  Map<int, Produto> produtosMap = {};

  bool isLoading = true;
  String situacaoFiltro = 'TODAS';

  final List<String> opcoesFiltro = ['TODAS', 'ENTRADA', 'SAÍDA', 'CORREÇÕES'];

  @override
  void initState() {
    super.initState();
    _estoqueDao = GerenciadorEstoqueDao();
    _produtoDao = ProdutoDao();
    _carregarDados();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      final lancamentosDoBanco = await _estoqueDao.listarTodos();
      final produtosDoBanco = await _produtoDao.listarTodos();

      final Map<int, Produto> mapP = {
        for (var p in produtosDoBanco)
          if (p.id != null) p.id!: p,
      };

      setState(() {
        todosOsLancamentos = lancamentosDoBanco;
        produtosMap = mapP;
      });

      _filtrarLista();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar movimentações: $e");
      setState(() => isLoading = false);
    }
  }

  void _filtrarLista() {
    String textoDigitado = _buscaController.text.toLowerCase();

    setState(() {
      List<GerenciadorEstoque> filtradosParcial = todosOsLancamentos.where((
        lancamento,
      ) {
        bool matchNfe = lancamento.numeroNfe.toLowerCase().contains(
          textoDigitado,
        );
        bool matchSituacao = true;
        if (situacaoFiltro == 'ENTRADA') {
          matchSituacao =
              lancamento.situacao == 'ENTRADA' && lancamento.numeroNfe != '000';
        } else if (situacaoFiltro == 'SAÍDA') {
          matchSituacao =
              lancamento.situacao == 'SAIDA' && lancamento.numeroNfe != '000';
        } else if (situacaoFiltro == 'CORREÇÕES') {
          matchSituacao = lancamento.numeroNfe == '000';
        }
        return matchNfe && matchSituacao;
      }).toList();

      List<GerenciadorEstoque> listaAgrupada = [];
      Set<String> nfesProcessadas = {};

      for (var lancamento in filtradosParcial) {
        if (lancamento.numeroNfe == '000') {
          listaAgrupada.add(lancamento);
        } else {
          if (!nfesProcessadas.contains(lancamento.numeroNfe)) {
            listaAgrupada.add(lancamento);
            nfesProcessadas.add(lancamento.numeroNfe);
          }
        }
      }

      lancamentosFiltrados = listaAgrupada;
    });
  }

  String _formatarData(DateTime data) {
    String dia = data.day.toString().padLeft(2, '0');
    String mes = data.month.toString().padLeft(2, '0');
    String ano = data.year.toString();
    return "$dia/$mes/$ano";
  }

  void _mostrarDetalhesNfe(
    BuildContext context,
    GerenciadorEstoque lancamentoClicado,
  ) {
    List<GerenciadorEstoque> itensDestaNota = [];

    if (lancamentoClicado.numeroNfe == '000') {
      itensDestaNota = [lancamentoClicado];
    } else {
      itensDestaNota = todosOsLancamentos
          .where((l) => l.numeroNfe == lancamentoClicado.numeroNfe)
          .toList();
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            lancamentoClicado.numeroNfe == '000'
                ? 'Detalhes da Correção'
                : 'Itens da NFe: ${lancamentoClicado.numeroNfe}',
            style: textStyleBlackTituloPage,
          ),
          content: SizedBox(
            width: 600,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: itensDestaNota.length,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.grey.shade300),
              itemBuilder: (context, index) {
                final item = itensDestaNota[index];
                final produto = produtosMap[item.idProduto];
                final nomeProduto =
                    produto?.nome ?? 'Produto Excluído/Desconhecido';
                String textoBadgeModal = item.situacao;
                Color corBadgeModal = item.situacao == 'ENTRADA'
                    ? Colors.green.shade600
                    : Colors.red.shade600;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    nomeProduto,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Movimentado: ${item.quantidade.toInt()} un.'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: corBadgeModal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      textoBadgeModal,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Fechar',
                style: TextStyle(color: Color(0xFF1E293B)),
              ),
            ),
          ],
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
          const Text(
            "Movimentações de Estoque",
            style: textStyleBlackTituloPage,
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: CampoBuscaWidget(
                  texto: "Pesquisar por NFe",
                  prefixIcon: Icons.search_rounded,
                  controller: _buscaController,
                  onChanged: (val) => _filtrarLista(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: CampoDropdownWidget<String>(
                  label: '',
                  hintText: 'Filtrar Situação',
                  items: opcoesFiltro,
                  value: situacaoFiltro,
                  getLabel: (item) => item,
                  onSelected: (selecionado) {
                    setState(() {
                      situacaoFiltro = selecionado;
                      _filtrarLista();
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (lancamentosFiltrados.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Center(child: Text("Nenhuma movimentação encontrada.")),
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
                          flex: 2,
                          child: Text('NFe', style: _headerStyle()),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text('Produto', style: _headerStyle()),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Situação', style: _headerStyle()),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Data', style: _headerStyle()),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text('Ações', style: _headerStyle()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lancamentosFiltrados.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final lancamento = lancamentosFiltrados[index];
                      final bool isCorrecao = lancamento.numeroNfe == '000';

                      String textoProduto = '';
                      if (isCorrecao) {
                        final produto = produtosMap[lancamento.idProduto];
                        textoProduto = produto?.nome ?? 'Desconhecido';
                      } else {
                        int qtdItens = todosOsLancamentos
                            .where((l) => l.numeroNfe == lancamento.numeroNfe)
                            .length;
                        textoProduto = qtdItens > 1
                            ? '$qtdItens itens agrupados'
                            : '1 item';
                      }

                      final String dataFormatada = _formatarData(
                        lancamento.data,
                      );

                      String textoSituacao = isCorrecao
                          ? 'CORREÇÃO'
                          : lancamento.situacao;
                      Color corSituacao = Colors.grey.shade700;

                      if (isCorrecao) {
                        corSituacao = lancamento.situacao == 'SAIDA'
                            ? Colors.red.shade700
                            : Colors.blue.shade700;
                      } else {
                        if (textoSituacao == 'ENTRADA')
                          corSituacao = Colors.green.shade700;
                        if (textoSituacao == 'SAIDA')
                          corSituacao = Colors.red.shade700;
                      }

                      return InkWell(
                        onTap: () => _mostrarDetalhesNfe(context, lancamento),
                        hoverColor: Colors.blueGrey.shade50,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: [
                              // NFE
                              Expanded(
                                flex: 2,
                                child: Text(
                                  lancamento.numeroNfe,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 3,
                                child: Text(
                                  textoProduto,
                                  style: TextStyle(
                                    color: isCorrecao
                                        ? Colors.grey.shade800
                                        : Colors.blueGrey.shade600,
                                    fontStyle: isCorrecao
                                        ? FontStyle.normal
                                        : FontStyle.italic,
                                    fontWeight: isCorrecao
                                        ? FontWeight.normal
                                        : FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: corSituacao.withOpacity(0.1),
                                      border: Border.all(
                                        color: corSituacao.withOpacity(0.5),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      textoSituacao,
                                      style: TextStyle(
                                        color: corSituacao,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // DATA
                              Expanded(
                                flex: 2,
                                child: Text(
                                  dataFormatada,
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ),

                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.visibility,
                                      color: Colors.blueGrey,
                                    ),
                                    tooltip: '',
                                    onPressed: () => _mostrarDetalhesNfe(
                                      context,
                                      lancamento,
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

  TextStyle _headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.blueGrey.shade700,
    );
  }
}
