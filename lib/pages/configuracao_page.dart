import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:projeto_enfermagem_desktop/widgets/campo_texto_widget.dart';

import '../theme/theme.dart';

class ConfiguracaoPage extends StatefulWidget{
  const ConfiguracaoPage({super.key});
  
  @override
  State<StatefulWidget> createState() => _ConfiguracaoPageState();

}

class _ConfiguracaoPageState extends State<ConfiguracaoPage>{
  final TextEditingController _instituicaoController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _cnpjController = TextEditingController();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 800,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: cinzaFundo,
              child: Text("Configurações", style: textStyleBlackTituloPage)
            ),

            const SizedBox(height: 26),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dados das Instituição", style: textStyleBlackTituloPage),
                        const SizedBox(height: 12),
                        CampoTextoWidget(
                          label: "Nome da Instituição",
                          controller: _instituicaoController,
                        ),
                        CampoTextoWidget(
                          label: "CNPJ",
                          controller: _cnpjController,
                          inputFormatter: [
                            cnpjMask,
                          ],
                          hintText: "00.000.000/0000-00",
                          validator: validarCnpj,
                        ),
                        CampoTextoWidget(
                          label: "Endereço",
                          controller: _enderecoController,
                        ),
                        CampoTextoWidget(
                          label: "Telefone",
                          controller: _telefoneController,
                          hintText: "(00) 00000-0000",
                          inputFormatter: [
                            telefoneMask,
                          ],
                          validator: validarTelefone,
                        ),
                      ],
                    ),
              ),
            )
          ],
      ),
    ),
  );

  // validador de CNPJ
  String? validarCnpj(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$');
    if (!regex.hasMatch(value)) {
      return "CNPJ inválido";
    }
    return null;
  }

  // mascara de CNPJ
  var cnpjMask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: { "#": RegExp(r'[0-9]') },
  );

  // validor de telefone
  String? validarTelefone(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^\(\d{2}\)\s\d{5}-\d{4}$');

    if (!regex.hasMatch(value)) {
      return "Telefone inválido";
    }
    return null;
  }

  // máscara de telefone
  var telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: { "#": RegExp(r'[0-9]') },
  );
}