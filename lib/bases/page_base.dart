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

  Widget _buildGeral() => Container(
        color: cinzaFundo,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            widget.body,
          ]),
        ),
  );
}