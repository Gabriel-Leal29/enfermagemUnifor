import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projeto_enfermagem_desktop/exceptions/consulta_exception.dart';
import 'package:projeto_enfermagem_desktop/pages/consulta/dialog_adicionar_consulta.dart';
import 'package:projeto_enfermagem_desktop/service/consulta_service.dart';
import 'package:projeto_enfermagem_desktop/service/impressao_service.dart';
import 'package:projeto_enfermagem_desktop/service/paciente_service.dart';
import 'package:projeto_enfermagem_desktop/toast/show_toast.dart';

import '../../DTO/consulta_details.dart';
import '../../DTO/consulta_produto_details.dart';
import '../../bases/page_base.dart';
import '../../model/paciente.dart';
import '../../theme/theme.dart';
import '../../widgets/button_amarelo_widget.dart';

class ConsultaPage extends StatefulWidget{
  const ConsultaPage({super.key});

  @override
  State<StatefulWidget> createState() => ConsultaPageState();

}

class ConsultaPageState extends State<ConsultaPage>{
  final ConsultaService _consultaService = ConsultaService();
  final PacienteService _pacienteService = PacienteService();
  final ImpressaoService _impressaoService = ImpressaoService();
  late ConsultaDetails consulta;

  bool _carregando = true;
  final TextEditingController _buscaController = TextEditingController();
  late List<ConsultaDetails> _consultas = [];
  late List<Paciente> _pacientes;

  @override
  void initState(){
    super.initState();
    buscarConsultas();


    consulta = ConsultaDetails(
      id: 1,
      responsavel: "Enfermeira Maria",
      demanda: "Curativo e medicação",
      data: DateTime.now(),
      observacao: "Paciente apresentou melhora significativa.",

      paciente: Paciente(
        id: 1,
        nome: "João da Silva",
        matricula: "2023001",
        cpf: "123.456.789-00",
        idTipoPaciente: 1,
      ),

      produtos: [
        ConsultaProdutoDetails(
          produto: Produto(
            id: 1,
            nome: "Dipirona 500mg",
            estoque: 120,
          ),
          quantidade: 2,
        ),
        ConsultaProdutoDetails(
          produto: Produto(
            id: 2,
            nome: "Soro Fisiológico 0.9%",
            estoque: 50,
          ),
          quantidade: 1,
        ),
      ],
    );
  }


  @override
  void dispose(){
    _buscaController.dispose();


    super.dispose();
  }


  Future<void> buscarConsultas() async {
    try{
      //final consultas = await _consultaService.listarConsultas();
      final pacientes = await _pacienteService.buscarPacientes();

      setState(() {
        //_consultas = consultas;
        _pacientes = pacientes;
        _carregando = false;
      });

    }on ConsultaException catch(e){
      showToast(context, message: e.message, type: ToastType.error);
    }
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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => DialogAdicionarConsulta(
                            pacientes: _pacientes
                        ),
                      );
                    },

                ),
                ButtonAmareloWidget(
                  texto: "teste imprimir",
                  icone: Icons.add,
                    onPressed: () async {
                      await _impressaoService.imprimirConsulta(consulta);
                    }
                ),
              ],
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: "Buscar por nome ou data...",
                prefixIcon: const Icon(Icons.search, color: menuItemNaoSelecionado),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: azulUnifor),
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (_carregando)
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
                    headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade50),
                    dataRowMinHeight: 60,
                    dataRowMaxHeight: 60,
                    horizontalMargin: 24,
                    columns: const [
                      DataColumn(label: Text('Paciente', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                      DataColumn(label: Text('Data', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                      DataColumn(label: Text('Queixa', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                      DataColumn(label: Text('Produtos Utilizados', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                      DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    ],
                    rows: _consultas.map((consulta) {
                      return DataRow(
                        cells: [
                          DataCell(Text(consulta.paciente.nome, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(consulta.data as String)),
                          DataCell(Text(consulta.demanda)),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline, color: Colors.blue),
                                  onPressed: () => null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.print_outlined, color: Colors.red),
                                  onPressed: null,
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
          ],
        ),
      );
    }
}