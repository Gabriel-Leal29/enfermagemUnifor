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
              child: Stack(
                children: [
                  Positioned.fill(
                      child: SingleChildScrollView(
                        child: widget.conteudo
                      )
                  ),
                ],
              )
            )
          ],
        )
    ),
  );
}