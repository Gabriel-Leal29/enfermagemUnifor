import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projeto_enfermagem_desktop/theme/theme.dart';

class ConfiguracaoBase extends StatefulWidget{
  const ConfiguracaoBase({
    required this.barraLateral,
    required this.conteudo,
    super.key
  });
  
  final Widget barraLateral;
  final Widget conteudo;

  @override
  State<StatefulWidget> createState() => _ConfiguracaoBaseState();
}

class _ConfiguracaoBaseState extends State<ConfiguracaoBase>{
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