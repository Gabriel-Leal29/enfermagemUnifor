import 'package:flutter/material.dart';
import 'package:projeto_enfermagem_desktop/widgets/button_amarelo_widget.dart';
import 'package:projeto_enfermagem_desktop/widgets/campo_texto_widget.dart';
import '../../model/consulta_produto.dart';
import '../../model/paciente.dart';
import '../../theme/theme.dart';
import 'package:intl/intl.dart';

class DialogAdicionarConsulta extends StatefulWidget {
  final List<Paciente> pacientes;

  const DialogAdicionarConsulta({super.key, required this.pacientes});

  @override
  State<DialogAdicionarConsulta> createState() => _DialogAdicionarConsultaState();
}

class Produto {
  final int? id;
  final String nome;
  final int estoque;
  final String descricao;

  Produto({
    this.id = 2,
    required this.nome,
    this.estoque = 4,
    this.descricao = "Jorge",
  });
}

class _DialogAdicionarConsultaState extends State<DialogAdicionarConsulta> {
  Paciente? _pacienteSelecionado;

  final TextEditingController _obsController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  late TextEditingController _estoqueController = TextEditingController();
  final DateTime _dataSelecionada = DateTime.now();

  late List<Produto> produtos;
  Produto? _produtoSelecionado;
  List<ConsultaProduto> _consultaProdutos = [];


  @override
  void initState(){
    super.initState();
    // produtos = [
    //   Produto(
    //     id: 1,
    //     estoque: 13,
    //     descricao: "Nome dele"
    //   ),
    //   Produto(
    //       id: 2,
    //       estoque: 3,
    //       descricao: "Nome swss"
    //   ),
    //   Produto(
    //       id: 3,
    //       estoque: 153,
    //       descricao: "abc wwaaaa"
    //   ),
    //   Produto(
    //       id: 4,
    //       estoque: 4,
    //       descricao: "julima dele"
    //   ),
    // ];
  }

  @override
  void dispose() {
    _obsController.dispose();
    _dataController.dispose();
    _quantidadeController.dispose();
    _estoqueController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime agora = DateTime.now();
    final DateTime dataMinima = agora.subtract(const Duration(days: 15));
    final DateTime dataMaxima = agora.add(const Duration(days: 60));

    final DateTime? colhida = await showDatePicker(
      context: context,
      initialDate: agora,
      firstDate: dataMinima,
      lastDate: dataMaxima,
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: azulUnifor, // cor do cabeçalho e do dia selecionado
              onPrimary: Colors.white, // cor do texto sobre o primary
              onSurface: Colors.black, // cor do texto dos dias (números)
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: azulUnifor, // cor dos botões "OK" e "Cancelar"
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (colhida != null) {
      setState(() {
        _dataController.text = DateFormat('dd/MM/yyyy').format(colhida);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 750,
        height: 720,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Dados da Consulta", style: textStyleBlackTituloPage,),

                      const SizedBox(height: 12),

                      Autocomplete<Paciente>(
                        optionsBuilder: (textValue) {
                          if (textValue.text.isEmpty) return const Iterable.empty();
                          return widget.pacientes.where((p) => p.nome
                              .toLowerCase()
                              .contains(textValue.text.toLowerCase()));
                        },
                        displayStringForOption: (p) => p.nome,
                        onSelected: (p) => setState(() => _pacienteSelecionado = p),
                        fieldViewBuilder: (context, ctrl, node, onSubmitted) {
                          return CampoTextoWidget(
                            focusNode: node,
                            obrigatorio: true,
                            controller: ctrl,
                            label: 'Paciente',
                            hintText: "Selecione o paciente",
                            sufixoIcon: Icon(Icons.keyboard_arrow_down),
                          );
                        },
                      ),

                      const SizedBox(height: 6),

                      CampoTextoWidget(
                          label: "Data Consulta",
                          hintText: "dd/MM/aaaa",
                          controller: _dataController,
                          onTap: () => _selecionarData(context),
                          readOnly: true,
                          sufixoIcon: Icon(Icons.calendar_month, size: 22),
                      ),

                      const SizedBox(height: 6),

                      CampoTextoWidget(
                          label: "Queixa",
                          minLines: 3,
                          maxLines: 6,
                          hintText: "Descreva a queixa do paciente",
                          controller: _obsController
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Autocomplete<Produto>(
                              optionsBuilder: (textValue) {
                                if (textValue.text.isEmpty) return const Iterable.empty();
                                return produtos.where((p) => p.descricao
                                    .toLowerCase()
                                    .contains(textValue.text.toLowerCase()));
                              },
                              displayStringForOption: (p) => p.descricao,
                              onSelected: (p) => setState(() {
                                _produtoSelecionado = p;
                                _estoqueController.text = p.estoque.toString();
                              }),
                              fieldViewBuilder: (context, ctrl, node, onSubmitted) {
                                return CampoTextoWidget(
                                  focusNode: node,
                                  controller: ctrl,
                                  label: 'Produtos / Medicamentos Utilizados',
                                  hintText: "Selecione o medicamento",
                                  sufixoIcon: Icon(Icons.keyboard_arrow_down),
                                );
                              },
                            ),
                          ),

                          SizedBox(width: 8),

                          SizedBox(
                            width: 100,
                            child: CampoTextoWidget(
                              label: "Estoque",
                              readOnly: true,
                              hintText:"0",
                              controller: _estoqueController,
                            ),
                          ),

                          SizedBox(width: 8),

                          SizedBox(
                            width: 100,
                            child: CampoTextoWidget(
                              label: "Quantidade",
                              hintText:"0",
                              controller: _quantidadeController,
                            ),
                          ),

                          SizedBox(width: 8),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 38), // espaço do label
                              SizedBox(
                                width: 60,
                                height: 50,
                                child: ButtonAmareloWidget(
                                  texto: "+",
                                  onPressed: () => null //vai adicionar o produto na consulta,
                                ),
                              ),
                            ],
                          )
                        ]
                      ),

                      Column(
                        children: _consultaProdutos.map((produto) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: cinzaFundo,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    produto.id.toString(),
                                    style: textStyleBlackLabel,
                                  ),
                                ),

                                Text(
                                  "Qtd: ${produto.quantProduto}",
                                  style: textStyleBlackLabel,
                                ),

                                const SizedBox(width: 8),

                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _consultaProdutos.remove(produto);
                                    });
                                  },
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}