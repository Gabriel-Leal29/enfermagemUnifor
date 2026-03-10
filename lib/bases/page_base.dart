import 'package:flutter/material.dart';

import '../theme/theme.dart';

class PageBase extends StatefulWidget{
  const PageBase({
    required this.body,
    super.key
  });

  final Widget body;

  @override
  State<StatefulWidget> createState() => _PageBaseState();
}

class _PageBaseState extends State<PageBase>{
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 800, // TODO: olhar a melhor altura no andamento do desenvolvimento
    child: _buildGeral(),
  );

  Widget _buildGeral() => Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blueGrey,
            child: Text("E", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          widget.body,
        ]),
      )
  );
}