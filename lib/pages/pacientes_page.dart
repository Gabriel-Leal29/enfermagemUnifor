import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../bases/page_base.dart';
import '../model/paciente.dart';
import '../service/paciente_service.dart';
import '../theme/theme.dart';
import '../toast/show_toast.dart';
import '../widgets/button_amarelo_widget.dart';
import '../widgets/campo_drop_down_widget.dart';
import '../widgets/campo_texto_widget.dart';
import '../widgets/campo_busca_widget.dart';

class PacientesPage extends StatefulWidget {
  const PacientesPage({super.key});

  @override
  State<PacientesPage> createState() => _PacientesPageState();
}

class _PacientesPageState extends State<PacientesPage> {
  final TextEditingController _buscaController = TextEditingController();
  String _filtroAtual = 'Todos';
  final List<String> _filtros = ['Todos', 'Aluno', 'Funcionário', 'Visitante'];

  final PacienteService _pacienteService = PacienteService();
  List<Paciente> _pacientes = []; 
  List<Paciente> _pacientesFiltrados = []; 
  bool _carregando = true;

  
  int _paginaAtual = 1;
  final int _itensPorPagina = 10;

  @override
  void initState() {
    super.initState();
    _carregarDados(); 
  }

  Future<void> _carregarDados() async {
    try {
      final dados = await _pacienteService.buscarPacientes();
      setState(() {
        _pacientes = dados;
        _filtrarPacientes(); 
        _carregando = false;
      });
    } catch (e) {
      showToast(context, message: "Erro ao carregar pacientes", type: ToastType.error);
    }
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _filtrarPacientes() {
    setState(() {
      _pacientesFiltrados = _pacientes.where((paciente) {
        final tipoPaciente = _getDescricaoTipo(paciente.idTipoPaciente);
        final passouFiltroTipo = _filtroAtual == 'Todos' || tipoPaciente == _filtroAtual;

        final termoBusca = _buscaController.text.toLowerCase();
        final passouFiltroTexto = termoBusca.isEmpty || 
                                  paciente.nome.toLowerCase().contains(termoBusca) || 
                                  (paciente.cpf?.contains(termoBusca) ?? false);

        return passouFiltroTipo && passouFiltroTexto;
      }).toList();
      
      
      _paginaAtual = 1;
    });
  }

  String _getDescricaoTipo(int idTipo) {
    if (idTipo == 1) return 'Aluno';
    if (idTipo == 2) return 'Funcionário';
    return 'Visitante';
  }

  int _getIdTipo(String descricao) {
    if (descricao == 'Aluno') return 1;
    if (descricao == 'Funcionário') return 2;
    return 3;
  }

  Widget _buildBadgeTipo(String tipo) {
    Color corFundo = Colors.transparent;
    Color corTexto = Colors.black87;

    if (tipo == 'Aluno') {
      corFundo = azulUniforSelecionado;
      corTexto = Colors.white;
    } else if (tipo == 'Funcionário') {
      corFundo = amareloUnifor;
      corTexto = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(16),
        border: tipo == 'Visitante' ? Border.all(color: Colors.grey.shade300) : null,
      ),
      child: Text(
        tipo,
        style: TextStyle(color: corTexto, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _mostrarModalPaciente({Paciente? paciente}) {
    final nomeController = TextEditingController(text: paciente?.nome ?? "");
    final cpfController = TextEditingController(text: paciente?.cpf ?? "");
    final matriculaController = TextEditingController(text: paciente?.matricula ?? "");
    
    String? tipoSelecionado = paciente != null ? _getDescricaoTipo(paciente.idTipoPaciente) : null;

    var cpfMask = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: { "#": RegExp(r'[0-9]') },
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) { 
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(paciente == null ? "Novo Paciente" : "Editar Paciente", style: textStyleBlackTituloPage),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CampoTextoWidget(
                        label: "Nome Completo",
                        controller: nomeController,
                        hintText: "Ex: João da Silva",
                        obrigatorio: true,
                        mostrarBordaCinza: true,
                      ),
                      CampoTextoWidget(
                        label: "CPF",
                        controller: cpfController,
                        inputFormatter: [cpfMask],
                        hintText: "000.000.000-00", 
                        mostrarBordaCinza: true, 
                      ),
                      CampoDropdownWidget<String>(
                        key: ValueKey(tipoSelecionado), 
                        label: "Tipo de Paciente",
                        hintText: "Selecione", 
                        items: const ['Aluno', 'Funcionário', 'Visitante'],
                        value: tipoSelecionado,
                        onSelected: (val) {
                          setStateModal(() {
                            tipoSelecionado = val;
                          });
                        },
                      ),
                      if (tipoSelecionado != 'Visitante')
                        CampoTextoWidget(
                          label: "Matrícula",
                          controller: matriculaController,
                          hintText: "Ex: 2024001", 
                          mostrarBordaCinza: true, 
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                ButtonAmareloWidget(
                  texto: "Cancelar",
                  isCancelamento: true,
                  onPressed: () => Navigator.pop(context),
                ),
                ButtonAmareloWidget(
                  texto: "Salvar",
                  onPressed: () async {
                    if (tipoSelecionado == null) {
                      showToast(context, message: "Selecione o tipo de paciente!", type: ToastType.error);
                      return;
                    }

                    try {
                      final novoPaciente = Paciente(
                        id: paciente?.id, 
                        nome: nomeController.text,
                        cpf: cpfController.text.isEmpty ? null : cpfController.text, 
                        matricula: tipoSelecionado == 'Visitante' ? null : matriculaController.text,
                        idTipoPaciente: _getIdTipo(tipoSelecionado!),
                      );

                      await _pacienteService.salvarPaciente(novoPaciente);
                      
                      if (mounted) {
                        Navigator.pop(context); 
                        _carregarDados(); 
                        showToast(context, message: "Salvo com sucesso!", type: ToastType.success);
                      }
                    } catch (e) {
                      showToast(context, message: e.toString(), type: ToastType.error);
                    }
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _confirmarExclusao(Paciente paciente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Atenção"),
        content: Text("Tem certeza que deseja excluir o paciente ${paciente.nome}?"),
        actions: [
          ButtonAmareloWidget(
            texto: "Cancelar",
            isCancelamento: true,
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: redAlert),
            onPressed: () async {
              try {
                await _pacienteService.excluirPaciente(paciente.id!);
                if (mounted) {
                  Navigator.pop(context);
                  _carregarDados();
                  showToast(context, message: "Excluído com sucesso!", type: ToastType.success);
                }
              } catch (e) {
                showToast(context, message: e.toString(), type: ToastType.error);
              }
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    final int totalRegistros = _pacientesFiltrados.length;
    int totalPaginas = (totalRegistros / _itensPorPagina).ceil();
    if (totalPaginas == 0) totalPaginas = 1; 

    int startIndex = (_paginaAtual - 1) * _itensPorPagina;
    int endIndex = startIndex + _itensPorPagina;
    if (endIndex > totalRegistros) endIndex = totalRegistros;

    
    final List<Paciente> pacientesExibidos = _pacientesFiltrados.sublist(startIndex, endIndex);

    return PageBase(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Pacientes", style: textStyleBlackTituloPage),
              ButtonAmareloWidget(
                texto: "Novo Paciente",
                icone: Icons.add,
                onPressed: () => _mostrarModalPaciente(), 
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CampoBuscaWidget(
                  controller: _buscaController,
                  texto: "Buscar por nome ou CPF...",
                  prefixIcon: Icons.search_rounded,
                  onChanged: (value) => _filtrarPacientes(),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 48, 
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300), 
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filtroAtual,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    focusColor: Colors.transparent,
                    icon: const Icon(Icons.keyboard_arrow_down, color: menuItemNaoSelecionado),
                    items: _filtros.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (novoValor) {
                      setState(() {
                        if (novoValor != null) {
                          _filtroAtual = novoValor;
                          _filtrarPacientes(); 
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (_carregando)
            const Center(child: CircularProgressIndicator())
          else if (_pacientesFiltrados.isEmpty)
            const Center(child: Text("Nenhum paciente encontrado.", style: TextStyle(color: Colors.grey, fontSize: 16)))
          else
            Column(
              children: [
                
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
                      headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade50),
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 60,
                      horizontalMargin: 24,
                      columns: const [
                        DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                        DataColumn(label: Text('Matrícula', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                        DataColumn(label: Text('CPF', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                        DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                        DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                      ],
                      
                      rows: pacientesExibidos.map((paciente) {
                        return DataRow(
                          onSelectChanged: (_) {}, 
                          cells: [
                            DataCell(Text(paciente.nome, style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(paciente.matricula?.isNotEmpty == true ? paciente.matricula! : '-')), 
                            DataCell(Text(paciente.cpf?.isNotEmpty == true ? paciente.cpf! : '-')),
                            DataCell(_buildBadgeTipo(_getDescricaoTipo(paciente.idTipoPaciente))),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                    onPressed: () => _mostrarModalPaciente(paciente: paciente), 
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _confirmarExclusao(paciente),
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
                
                const SizedBox(height: 16),
                
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$totalRegistros registro(s) encontrado(s)",
                      style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 20),
                          color: Colors.grey.shade700,
                          onPressed: _paginaAtual > 1 
                            ? () => setState(() => _paginaAtual--) 
                            : null, 
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Página $_paginaAtual de $totalPaginas",
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, size: 20),
                          color: Colors.grey.shade700,
                          onPressed: _paginaAtual < totalPaginas 
                            ? () => setState(() => _paginaAtual++) 
                            : null, 
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
        ],
      ),
    );
  }
}