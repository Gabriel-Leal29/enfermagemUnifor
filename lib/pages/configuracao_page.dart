import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projeto_enfermagem_desktop/widgets/campo_texto_widget.dart';

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
  Widget build(BuildContext context) => Column(
    children: [
      Text("Configurações"),
      SizedBox(
        child: Column(
          children: [
            CampoTextoWidget(
              label: "Nome da Instituição",
              controller: _instituicaoController,
            ),
            CampoTextoWidget(
              label: "CNPJ",
              controller: _cnpjController,
              inputFormatter: [
                FilteringTextInputFormatter.digitsOnly,
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
              inputFormatter: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: validarTelefone,
            ),
          ],
        )
      ),
    ],
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

  //validor de telefone
  String? validarTelefone(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^\(\d{2}\)\s\d{5}-\d{4}$');

    if (!regex.hasMatch(value)) {
      return "Telefone inválido";
    }
    return null;
  }
}