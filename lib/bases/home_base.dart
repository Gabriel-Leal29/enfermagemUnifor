import 'package:flutter/material.dart';
import 'package:projeto_enfermagem_desktop/theme/theme.dart';

class HomeBase extends StatefulWidget{
  const HomeBase({
    required this.barraLateral,
    required this.conteudo,
    super.key
  });
  
  final Widget barraLateral;
  final Widget conteudo;

  @override
  State<StatefulWidget> createState() => _HomeBaseState();
}

class _HomeBaseState extends State<HomeBase>{
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: cinzaFundo,
    body: SafeArea(
        child: Row(
          children: [
            // menu lateral
            SizedBox(
              width: 290,
              child: Container(
                color: azulUnifor,
                child: widget.barraLateral,
              ),
            ),

            // linha divisória
            VerticalDivider(width: 1, color: Colors.transparent),

            // lado direito
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: widget.conteudo,
                    ),
                  )
                ],
              ),
            )
          ],
        )
    ),
  );

  Widget _buildHeader() => Container(
    height: 70,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(
        bottom: BorderSide(color: Color(0xFFE5E7EB)),
      ),
    ),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sistema de Enfermagem",
              style: textStyleBlack,
            ),
            Text(
              "UNIFOR-MG · Gestão de Atendimentos",
              style: textStyleSubTituloHeader,
            ),
          ],
        ),

        const Spacer(),

        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),

        const SizedBox(width: 8),

        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blueGrey,
          child: Text("E", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}