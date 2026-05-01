import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projeto_enfermagem_desktop/exceptions/consulta_exception.dart';
import 'package:projeto_enfermagem_desktop/toast/show_toast.dart';
import 'package:projeto_enfermagem_desktop/widgets/button_amarelo_widget.dart';
import 'package:projeto_enfermagem_desktop/widgets/campo_texto_widget.dart';
import '../../DTO/consulta_details.dart';
import '../../DTO/consulta_produto_details.dart';
import '../../model/paciente.dart';
import '../../model/produto.dart';
import '../../service/consulta_service.dart';
import '../../theme/theme.dart';
import 'package:intl/intl.dart';

import '../../widgets/campo_autocomplete_widget.dart';

class DialogAdicionarConsulta extends StatefulWidget {
  final List<Paciente> pacientes;
  final List<Produto> produtos;
  final ConsultaDetails? consulta;

  const DialogAdicionarConsulta({super.key, required this.pacientes, required this.produtos, this.consulta});

  @override
  State<DialogAdicionarConsulta> createState() => _DialogAdicionarConsultaState();
}

class _DialogAdicionarConsultaState extends State<DialogAdicionarConsulta> {
  final ConsultaService _consultaService = ConsultaService();

  Paciente? _pacienteSelecionado;

  final TextEditingController _demandaController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _estoqueController = TextEditingController();
  final TextEditingController _obsController = TextEditingController();
  final TextEditingController _responsavelController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();

  Produto? _produtoSelecionado;
  final TextEditingController _produtoBuscaController = TextEditingController();
  List<ConsultaProdutoDetails> _produtosAdicionados = [];



  @override
  void initState(){
    super.initState();

    if(widget.consulta != null){
      // vai editar a consulta
      final c = widget.consulta;

      _demandaController.text = c!.demanda;
      _dataController.text = c.dataFormatada;
      _dataSelecionada = c.data;
      _obsController.text = c.observacao ?? "";
      _responsavelController.text = c.responsavel ?? "";
      _pacienteSelecionado = c.paciente;
      _produtosAdicionados = c.produtos;
    }else{
      setState(() {
        _dataController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _demandaController.dispose();
    _dataController.dispose();
    _quantidadeController.dispose();
    _estoqueController.dispose();
    _obsController.dispose();
    _responsavelController.dispose();
    _produtoBuscaController.dispose();
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
        _dataSelecionada = colhida;
      });
    }
  }

  void _adicionarProduto() {
    if (_produtoSelecionado == null) return;

    final quantidade = int.tryParse(_quantidadeController.text) ?? 0;

    if(quantidade > _produtoSelecionado!.estoque){
      showToast(context, message: "A quantidade não pode ser superior ao estoque do produto atual!", type: ToastType.warning);
      return;
    }

    if (quantidade <= 0) {
      showToast(context, message: "A quantidade deve ser maior que 0!", type: ToastType.warning);
    }


    setState(() {
      final index = _produtosAdicionados.indexWhere(
            (e) => e.produto.id == _produtoSelecionado!.id,
      );

      if (index != -1) {
        // já existe  soma quantidade
        _produtosAdicionados[index] = ConsultaProdutoDetails(
          produto: _produtoSelecionado!,
          quantidade:
          _produtosAdicionados[index].quantidade + quantidade,
        );
      } else {
        // novo produto  adiciona
        _produtosAdicionados.add(
          ConsultaProdutoDetails(
            produto: _produtoSelecionado!,
            quantidade: quantidade,
          ),
        );
      }

      _limparCamposProduto();
    });
  }

  void _limparCamposProduto(){
    _produtoBuscaController.clear();
    _produtoSelecionado = null;
    _quantidadeController.clear();
    _estoqueController.clear();
  }

  void _cadastrarConsulta() async {
    try{
      if(_pacienteSelecionado == null){
        showToast(context, message: "O paciente deve ser selecionado!", type: ToastType.warning);
        return;
      }

      final consultaDto = ConsultaDetails(
          id: widget.consulta?.id,
          paciente: _pacienteSelecionado!,
          responsavel: _responsavelController.text.isEmpty ? null : _responsavelController.text,
          demanda: _demandaController.text,
          observacao: _obsController.text.isEmpty ? null : _obsController.text,
          data: _dataSelecionada,
          produtos: _produtosAdicionados
      );

      if(widget.consulta != null){
        // edita a consulta
        await _consultaService.editarConsulta(consultaDto);
        showToast(context, message: "Consulta editada com sucesso!", type: ToastType.success);
      }else{
        // cadastra consulta
        await _consultaService.criarConsultaCompleta(consultaDto);
        showToast(context, message: "Consulta cadastrada com sucesso!", type: ToastType.success);
      }

      Navigator.pop(context, true);
    } on ConsultaException catch(e){
      showToast(context, message: e.message, type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 750,
        height: 800,
        padding: const EdgeInsets.all(6.0),
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dados da Consulta", style: textStyleBlackTituloPage,),
                    
                        const SizedBox(height: 12),

                        CampoAutocompleteWidget<Paciente>(
                          label: "Paciente",
                          valorInicial: _pacienteSelecionado,
                          items: widget.pacientes,
                          obrigatorio: true,
                          hintText: "Selecione o paciente",
                          getLabel: (p) => p.nome,
                          onSelected: (p) {
                            setState(() {
                              _pacienteSelecionado = p;
                            });
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
                            label: "Responsável",
                            hintText: "Responsável pelo paciente",
                            controller: _responsavelController
                        ),
                    
                        const SizedBox(height: 6),
                    
                        CampoTextoWidget(
                            label: "Queixa",
                            minLines: 3,
                            maxLines: 6,
                            hintText: "Descreva a queixa do paciente",
                            controller: _demandaController
                        ),
                    
                        const SizedBox(height: 6),
                    
                        CampoTextoWidget(
                            label: "Observações",
                            controller: _obsController
                        ),
                    
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: CampoAutocompleteWidget<Produto>(
                                label: "Produtos / Medicamentos Utilizados",
                                items: widget.produtos,
                                controller: _produtoBuscaController,
                                hintText: "Selecione o medicamento...",
                                getLabel: (p) => p.nome,
                                onSelected: (p) {
                                  setState(() {
                                    _produtoSelecionado = p;
                                    _estoqueController.text = p.estoque.toString();
                                  });
                                },
                              ),
                            ),
                    
                            SizedBox(width: 8),
                    
                            SizedBox(
                              width: 120,
                              child: CampoTextoWidget(
                                label: "Estoque Atual",
                                readOnly: true,
                                hintText:"0",
                                controller: _estoqueController,
                              ),
                            ),
                    
                            SizedBox(width: 8),
                    
                            SizedBox(
                              width: 100,
                              child: CampoTextoWidget(
                                label: "Qtde. Gasta",
                                hintText:"0",
                                maxLines: 1,
                                controller: _quantidadeController,
                                inputFormatter: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                            ),
                    
                            SizedBox(width: 8),
                    
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 50), // espaço do label
                                SizedBox(
                                  width: 60,
                                  height: 50,
                                  child: ButtonAmareloWidget(
                                    texto: "+",
                                    onPressed: () => _adicionarProduto(), //vai adicionar o produto na consulta,
                                  ),
                                ),
                              ],
                            )
                          ]
                        ),
                    
                        const SizedBox(height: 8),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _produtosAdicionados.length,
                          itemBuilder: (context, index) {
                            final p = _produtosAdicionados[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: cinzaFundo,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.produto.nome,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text("Qtd: ${p.quantidade}"),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _produtosAdicionados.removeAt(index);
                                      });
                                    },
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                    
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ButtonAmareloWidget(texto: widget.consulta != null ? "Voltar" : "Cancelar", onPressed: () => Navigator.pop(context, false), isCancelamento: true,),

                            SizedBox(width: 24),

                            ButtonAmareloWidget(texto: widget.consulta != null ? "Editar" : "Salvar", onPressed: _cadastrarConsulta),
                          ],
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
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