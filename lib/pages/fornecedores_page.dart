import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../bases/page_base.dart';
import '../model/fornecedor.dart';
import '../service/fornecedor_service.dart';
import '../theme/theme.dart';
import '../toast/show_toast.dart';
import '../widgets/button_amarelo_widget.dart';
import '../widgets/campo_texto_widget.dart';

class FornecedoresPage extends StatefulWidget {
  const FornecedoresPage({super.key});

  @override
  State<FornecedoresPage> createState() => _FornecedoresPageState();
}

class _FornecedoresPageState extends State<FornecedoresPage> {
  final TextEditingController _buscaController = TextEditingController();
  final FornecedorService _fornecedorService = FornecedorService();
  
  List<Fornecedor> _fornecedores = [];
  List<Fornecedor> _fornecedoresFiltrados = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _buscaController.addListener(_filtrarFornecedores);
  }

  Future<void> _carregarDados() async {
    try {
      final dados = await _fornecedorService.buscarFornecedores();
      setState(() {
        _fornecedores = dados;
        _filtrarFornecedores();
        _carregando = false;
      });
    } catch (e) {
      showToast(context, message: "Erro ao carregar fornecedores", type: ToastType.error);
    }
  }

  void _filtrarFornecedores() {
    setState(() {
      final termoBusca = _buscaController.text.toLowerCase();
      _fornecedoresFiltrados = _fornecedores.where((fornecedor) {
        return termoBusca.isEmpty || 
               fornecedor.nome.toLowerCase().contains(termoBusca) || 
               (fornecedor.razaoSocial?.toLowerCase().contains(termoBusca) ?? false) ||
               fornecedor.cnpj.contains(termoBusca);
      }).toList();
    });
  }

  @override
  void dispose() {
    _buscaController.removeListener(_filtrarFornecedores);
    _buscaController.dispose();
    super.dispose();
  }

  void _mostrarModalFornecedor({Fornecedor? fornecedor}) {
    final nomeController = TextEditingController(text: fornecedor?.nome ?? "");
    final razaoSocialController = TextEditingController(text: fornecedor?.razaoSocial ?? "");
    final cnpjController = TextEditingController(text: fornecedor?.cnpj ?? "");
    
    var cnpjMask = MaskTextInputFormatter(
      mask: '##.###.###/####-##',
      filter: { "#": RegExp(r'[0-9]') },
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cinzaFundo,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(fornecedor == null ? "Novo Fornecedor" : "Editar Fornecedor", style: textStyleBlackTituloPage),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CampoTextoWidget(
                    label: "Nome Fantasia",
                    controller: nomeController,
                    obrigatorio: true,
                  ),
                  CampoTextoWidget(
                    label: "Razão Social",
                    controller: razaoSocialController,
                  ),
                  CampoTextoWidget(
                    label: "CNPJ",
                    controller: cnpjController,
                    inputFormatter: [cnpjMask],
                    obrigatorio: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ButtonAmareloWidget(
              texto: "Salvar",
              onPressed: () async {
                try {
                  final novoFornecedor = Fornecedor(
                    id: fornecedor?.id, 
                    nome: nomeController.text,
                    razaoSocial: razaoSocialController.text.isEmpty ? null : razaoSocialController.text,
                    cnpj: cnpjController.text,
                  );

                  await _fornecedorService.salvarFornecedor(novoFornecedor);
                  
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
      },
    );
  }

  void _confirmarExclusao(Fornecedor fornecedor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Atenção"),
        content: Text("Tem certeza que deseja excluir o fornecedor ${fornecedor.nome}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: redAlert),
            onPressed: () async {
              try {
                await _fornecedorService.excluirFornecedor(fornecedor.id!);
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
    return PageBase(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Fornecedores", style: textStyleBlackTituloPage),
              ButtonAmareloWidget(
                texto: "Novo Fornecedor",
                icone: Icons.add,
                onPressed: () => _mostrarModalFornecedor(), 
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          
          TextField(
            controller: _buscaController,
            decoration: InputDecoration(
              hintText: "Buscar por nome ou CNPJ...",
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
          else if (_fornecedoresFiltrados.isEmpty)
            const Center(child: Text("Nenhum fornecedor encontrado.", style: TextStyle(color: Colors.grey, fontSize: 16)))
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
                    DataColumn(label: Text('Nome Fantasia', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    DataColumn(label: Text('Razão Social', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    DataColumn(label: Text('CNPJ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                  ],
                  rows: _fornecedoresFiltrados.map((fornecedor) {
                    return DataRow(
                      cells: [
                        DataCell(Text(fornecedor.nome, style: const TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(Text(fornecedor.razaoSocial ?? '-')), 
                        DataCell(Text(fornecedor.cnpj)),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                onPressed: () => _mostrarModalFornecedor(fornecedor: fornecedor), 
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _confirmarExclusao(fornecedor),
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