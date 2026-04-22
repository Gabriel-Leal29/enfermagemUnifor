import 'package:flutter/material.dart';
import 'package:projeto_enfermagem_desktop/bases/home_base.dart';
import 'package:projeto_enfermagem_desktop/pages/produtos_page.dart';
import 'package:projeto_enfermagem_desktop/theme/theme.dart';
import '../pages/movimentacoes_page.dart';

import '../bases/page_base.dart';
import 'configuracao_page.dart';
import 'pacientes_page.dart';
import 'fornecedores_page.dart'; 


class Home extends StatefulWidget{
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home>{
  
  
  List<Widget> get _opcoesMenuLateral => [
    const Center(child: PageBase(body: Text("Dashboard"))), // 0
    const PacientesPage(), // 1
    const Center(child: PageBase(body: Text("Consultas"))), // 2 
    const Center(child: PageBase(body: ProdutosPage())), // 3 
    const Center(child: PageBase(body: MovimentacoesPage())), // 4 
    const FornecedoresPage(), // 5 
    const Center(child: PageBase(body: ConfiguracaoPage())), // 6
  ];

  int _selectedIndex = 5; 
  final String titulo = "UNIFOR-MG";
  final String subTitulo = "ENFERMAGEM";

  @override
  Widget build(BuildContext context) => HomeBase(
      barraLateral: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        children: [
          _buildBarraLateralHeader(titulo, subTitulo, Icons.favorite),
          
          
          _buildMenuItem("Dashboard", Icons.dashboard_rounded, 0),
          _buildMenuItem("Pacientes", Icons.people_alt_rounded, 1),
          _buildMenuItem("Consultas", Icons.medical_services_outlined, 2),
          _buildMenuItem("Produtos", Icons.inventory_2_outlined, 3),
          _buildMenuItem("Movimentações", Icons.move_to_inbox_outlined, 4),
          _buildMenuItem("Fornecedores", Icons.local_shipping_outlined, 5),
          
          const SizedBox(height: 16), 
          _buildMenuItem("Configurações", Icons.settings_rounded, 6),
        ],
      ),
      conteudo: _opcoesMenuLateral[_selectedIndex]
  );

  Widget _buildBarraLateralHeader(String titulo, String subTitulo, IconData icone) => Container(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.transparent)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: azulUnifor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icone, color: amareloUnifor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: textStyleGrayTitle),
              Text(subTitulo, style:  textStyleSubTituloAndMenuItem),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildMenuItem(String title, IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? azulUniforSelecionado
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : menuItemNaoSelecionado,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: isSelected? textStyleMenuItemSelecionado : textStyleSubTituloAndMenuItem,
              ),
            ],
          ),
        ),
      ),
    );
  }
}