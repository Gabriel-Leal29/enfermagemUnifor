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
    child: _buildGeral(),
  );

  Widget _buildGeral() => Container(
        color: cinzaFundo,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 30, 16, 30),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            widget.body,
          ]),
        ),
  );
}