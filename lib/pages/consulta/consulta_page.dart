import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto_enfermagem_desktop/dao/produto_dao.dart';
import 'package:projeto_enfermagem_desktop/exceptions/config_exception.dart';
import 'package:projeto_enfermagem_desktop/exceptions/consulta_exception.dart';
import 'package:projeto_enfermagem_desktop/pages/consulta/dialog_adicionar_consulta.dart';
import 'package:projeto_enfermagem_desktop/service/consulta_service.dart';
import 'package:projeto_enfermagem_desktop/service/impressao_service.dart';
import 'package:projeto_enfermagem_desktop/service/produtos_service.dart';
import 'package:projeto_enfermagem_desktop/toast/show_toast.dart';

import '../../DTO/consulta_details.dart';
import '../../bases/page_base.dart';
import '../../exceptions/paciente_exception.dart';
import '../../model/filtros/consulta_filtro.dart';
import '../../model/paciente.dart';
import '../../model/produto.dart';
import '../../service/paciente_service.dart';
import '../../theme/theme.dart';
import '../../widgets/button_amarelo_widget.dart';
import '../../widgets/campo_busca_widget.dart';
import '../../widgets/campo_texto_widget.dart';

class ConsultaPage extends StatefulWidget{
  const ConsultaPage({super.key});

  @override
  State<StatefulWidget> createState() => ConsultaPageState();

}

class ConsultaPageState extends State<ConsultaPage>{
  final ConsultaService _consultaService = ConsultaService();

  late ConsultaDetails consulta;
  bool _dadosCarregando = true;
  final TextEditingController _buscaController = TextEditingController();
  List<ConsultaDetails> _consultas = [];
  List<Paciente> _pacientes = [];
  List<Produto> _produtos = [];

  // variáveis da paginação
  int _paginaAtual = 0;
  int _tamanhoPagina = 10;
  int _totalRegistros = 0;

  // filtros
  final TextEditingController _dataInicialController = TextEditingController();
  final TextEditingController _dataFinalController = TextEditingController();



  @override
  void initState(){
    super.initState();
  }


  @override
  void dispose(){
    _buscaController.dispose();
    _dataInicialController.dispose();
    _dataFinalController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_dadosCarregando) {
      _carregarDados();

      setState(() {
        _dadosCarregando = false;
      });
    }
  }


  Future<void> _carregarDados() async {
    try {
      final filtro = _montarFiltro();
      final pacientes = await PacienteService().buscarPacientes();
      final produtos = await ProdutosService(ProdutoDao()).buscarTodosOsAtivos();

      final consultas = await _consultaService
          .listarConsultasPaginadoComFiltro(
        _paginaAtual,
        _tamanhoPagina,
        filtro,
      );

      final total = await _consultaService
          .getTotalConsultasComFiltro(filtro);

      setState(() {
        _consultas = consultas;
        _pacientes = pacientes;
        _produtos = produtos;
        _totalRegistros = total;
      });

    }on ConsultaException catch(e){
      if (!mounted) return;
      showToast(context, message: e.message, type: ToastType.error);
    }on PacienteException catch(e){
      if (!mounted) return;
      showToast(context, message: e.message, type: ToastType.error);
    }
  }

  Future<void> _imprimir(ConsultaDetails consulta) async {
    try {
      await ImpressaoService().imprimirConsulta(consulta);

      showToast(
          context, message: "PDF gerado com sucesso!", type: ToastType.success);
    } on ConsultaException catch (e) {
      if (!mounted) return;
      showToast(context, message: e.message, type: ToastType.error);
    } on ConfigException catch(e){
      if (!mounted) return;
      showToast(context, message: e.message, type: ToastType.error);
    }on Exception catch(e){
      showToast(context, message: "Erro ao realizar a impressão!", type: ToastType.error);
    }
  }

  Future<void> _removerConsulta(int idConsulta) async {
    try {
      await _consultaService.deletarConsulta(idConsulta);

      _carregarDados();

      showToast(
          context, message: "Consulta deletada com sucesso!", type: ToastType.success);
    } on ConsultaException catch (e) {
      if (!mounted) return;
      showToast(context, message: e.message, type: ToastType.error);
    }
  }

  Future<void> _selecionarData(BuildContext context, TextEditingController controller) async {
    final DateTime agora = DateTime.now();
    final DateTime dataMinima = agora.subtract(const Duration(days: 365));
    final DateTime dataMaxima = agora;

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
        controller.text = DateFormat('dd/MM/yyyy').format(colhida);
      });
    }

    _aplicarFiltro();
  }

  void _aplicarFiltro() {
    setState(() {
      _paginaAtual = 0;
    });

    _carregarDados();
  }

  ConsultaFiltro _montarFiltro() {
    DateTime? dataInicial;
    DateTime? dataFinal;

    if (_dataInicialController.text.isNotEmpty) {
      dataInicial = DateFormat('dd/MM/yyyy').parse(_dataInicialController.text);
    }

    if (_dataFinalController.text.isNotEmpty) {
      dataFinal = DateFormat('dd/MM/yyyy').parse(_dataFinalController.text).add(Duration(days: 1));
    }

    return ConsultaFiltro(
      nomePaciente: _buscaController.text,
      dataInicial: dataInicial,
      dataFinal: dataFinal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageBase(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Consultas", style: textStyleBlackTituloPage),
                ButtonAmareloWidget(
                  texto: "Nova Consulta",
                  icone: Icons.add,
                    onPressed: () async {
                      final resultado = await showDialog(
                        context: context,
                        builder: (_) => DialogAdicionarConsulta(
                          pacientes: _pacientes,
                          produtos: _produtos,
                        ),
                      );

                      if (resultado == true) {
                        _carregarDados();
                      }
                    }

                )
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CampoBuscaWidget(
                      onChanged: (value) {
                        _aplicarFiltro();
                      },
                      texto: "Buscar por nome...",
                      prefixIcon: Icons.search_rounded,
                      controller: _buscaController
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  //width: 200,
                  child: CampoTextoWidget(
                    label: "",
                    hintText: "Data inicial",
                    controller: _dataInicialController,
                    onTap: () => _selecionarData(context, _dataInicialController),
                    readOnly: true,
                    mostrarBordaCinza: true,
                    sufixoIcon: Icon(Icons.calendar_month, size: 22),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  //width: 200,
                  child: CampoTextoWidget(
                    label: "",
                    hintText: "Data final",
                    controller: _dataFinalController,
                    onTap: () => _selecionarData(context, _dataFinalController),
                    readOnly: true,
                    sufixoIcon: Icon(Icons.calendar_month, size: 22),
                    mostrarBordaCinza: true,
                  ),
                ),

                const SizedBox(width: 8),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48), // espaço do label
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: ButtonAmareloWidget(
                        texto: "Limpar Filtros",
                        //icone: Icons.clear,
                        onPressed: () {
                          _buscaController.clear();
                          _dataInicialController.clear();
                          _dataFinalController.clear();

                          _aplicarFiltro();
                        }, //vai adicionar o produto na consulta,
                      ),
                    ),
                  ],
                )
              ],
            ),

            SizedBox(height: 20),

            if (_dadosCarregando)
              const Center(child: CircularProgressIndicator())
            else if (_consultas.isEmpty)
              const Center(child: Text("Nenhum consultada encontrada.", style: TextStyle(color: Colors.grey, fontSize: 16)))
            else
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DataTable(
                      showCheckboxColumn: false,
                      dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                            (states) {
                          if (states.contains(WidgetState.hovered)) {
                            return azulSelecionadoDropDown.withOpacity(0.3);
                          }
                          return null;
                        },
                      ),
                      headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.white),
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 60,
                      horizontalMargin: 24,
                      columns: const [
                        DataColumn(label: Text("COD", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                        DataColumn(label: Text("Paciente", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                        DataColumn(label: Text("Data", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                        DataColumn(label: Text("Queixa", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                        DataColumn(label: Text("Produtos Utilizados", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                        DataColumn(label: Text("Ações", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                      ],
                      rows: _consultas.map((consulta) {
                        return DataRow(
                          onSelectChanged: (_) {},
                          cells: [
                            DataCell(
                              Text(
                                consulta.id.toString(),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            DataCell(
                                Text(
                                    consulta.paciente.nome,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                ),
                            ),

                            DataCell(
                                Text(consulta.dataFormatada),
                            ),

                            DataCell(
                              Text(
                                  consulta.demandaResumida,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ),

                            DataCell(
                              Text(
                                  consulta.medicamentosSimplificados,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ),
                            DataCell(
                              Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.info_outline, color: Colors.blue),
                                        onPressed: () async {
                                          final resultado = await showDialog(
                                            context: context,
                                            builder: (_) => DialogAdicionarConsulta(
                                              consulta: consulta,
                                              pacientes: _pacientes,
                                              produtos: _produtos,
                                            ),
                                          );

                                          if (resultado == true) {
                                            _carregarDados();
                                          }
                                        }
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.print_outlined, color: Colors.black54),
                                      onPressed: () => _imprimir(consulta),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _removerConsulta(consulta.id!),
                                    ),
                                  ],
                                ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                ),
              ),

            SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _paginaAtual > 0
                      ? () {
                    setState(() => _paginaAtual--);
                    _carregarDados();
                  }
                      : null,
                ),

                Text("Página ${_paginaAtual + 1}"),

                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: (_paginaAtual + 1) * _tamanhoPagina < _totalRegistros
                      ? () {
                    setState(() => _paginaAtual++);
                    _carregarDados();
                  }
                      : null,
                ),
              ],
            )
          ],
        ),
      );
    }
}