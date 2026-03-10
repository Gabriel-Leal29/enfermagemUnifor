import 'package:flutter/material.dart';
import 'package:projeto_enfermagem_desktop/bases/configuracao_base.dart';
import 'package:projeto_enfermagem_desktop/theme/theme.dart';

import '../bases/page_base.dart';

class ConfiguracaoPage extends StatefulWidget{
  const ConfiguracaoPage({super.key});

  @override
  State<StatefulWidget> createState() => _ConfiguracaoPageState();
}

class _ConfiguracaoPageState extends State<ConfiguracaoPage>{
  // lista dos widgets que vai ser usados na barra lateral
  List<Widget> get _opcoesMenuLateral => [
    Center(
      child: PageBase(
        body: Text("Exemplo page 1"),
      ),
    ),
    Center(
      child: PageBase(
        body: Text("Exemplo page 2"),
      ),
    ),
  ];

  int _selectedIndex = 0;
  final String titulo = "UNIFOR-MG";
  final String subTitulo = "ENFERMAGEM";

  @override
  Widget build(BuildContext context) => ConfiguracaoBase(
      barraLateral: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        children: [
          _buildBarraLateralHeader(titulo, subTitulo, Icons.favorite),
          //TODO: passa o nome do menu, icone e a posição na lista 0,1,2,3...
          _buildMenuItem("Título 1", Icons.dashboard_customize_rounded, 0),
          _buildMenuItem("Título 2", Icons.dashboard_customize_rounded, 1),
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
                ? const Color(0xFF243B5A) // fundo do item selecionado
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