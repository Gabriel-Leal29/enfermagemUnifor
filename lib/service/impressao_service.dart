import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:projeto_enfermagem_desktop/exceptions/config_exception.dart';
import 'package:projeto_enfermagem_desktop/service/config_service.dart';
import '../DTO/consulta_details.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../model/config.dart';

class ImpressaoService {
  final ConfigService _configService = ConfigService();
  Config? dados;

  Future<void> imprimirConsulta(ConsultaDetails consulta) async {
    try {
      dados = await _configService.buscarConfiguracoes();
      final pdfBytes = await _gerarPdf(consulta);

      final nomeImpressora = dados!.impressora;

      if (nomeImpressora != null && nomeImpressora.isNotEmpty) {
        final printers = await _configService.listarImpressoras();

        final printer = printers.firstWhere(
              (p) => p.name == nomeImpressora,
        );

        await Printing.directPrintPdf(
          printer: printer,
          onLayout: (format) async =>
              Uint8List.fromList(pdfBytes),
        );

        return;
      }

      // diálogo padrão caso n abra a impressora
      await Printing.layoutPdf(
        onLayout: (format) async =>
            Uint8List.fromList(pdfBytes),
      );
    }on ConfigException catch(e){
      print(e);
        rethrow;
    }
  }

  Future<Uint8List> _gerarPdf(ConsultaDetails c) async {
    final pdf = pw.Document();

    final bytes = await rootBundle.load('assets/images/logo_unifor_mg.jpg');
    final logoImage = pw.MemoryImage(bytes.buffer.asUint8List());

    if(dados == null){
      throw ConfigException("Preencha os dados nas configurações para realizar impressões!");
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              _buildHeader(logoImage),
              pw.SizedBox(height: 30),
              _buildConteudo(c),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(pw.MemoryImage logo){
    if(dados == null){
      throw Exception("Preencha os dados na tela de configurações!");
    }
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 1, color: PdfColors.grey300)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
            pw.Container(
              width: 80,
              height: 80,
              child: pw.Image(logo),
            ),

          pw.SizedBox(width: 20),

          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(dados!.nomeInstituicao.toUpperCase(), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),),

                if(dados!.cnpj != null)
                  pw.Text("CNPJ: ${dados!.cnpj}", style: const pw.TextStyle(fontSize: 10)),

                if(dados!.endereco != null)
                pw.Text("Endereço: ${dados!.endereco}", style: const pw.TextStyle(fontSize: 10)),

                if(dados!.telefone != null)
                pw.Text("Contato: ${dados!.telefone}", style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildConteudo(ConsultaDetails c) {
    return pw.Container(
        width: double.infinity, // 👈 ESSENCIAL
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "RELATÓRIO DE CONSULTA",
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Text("Paciente: ${c.paciente.nome}"),
            pw.Text("Tipo: ${_getTipoPaciente(c.paciente.idTipoPaciente)}"),
            if(c.paciente.matricula != null)
              pw.Text("Matrícula: ${c.paciente.matricula}"),

            pw.Text("Data: ${c.dataFormatada}"),

            pw.Text("Responsável: ${c.responsavel ?? "O próprio"}"),

            pw.SizedBox(height: 20),

            pw.Text(
              "Queixa / Observações:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(c.demanda),

            if(c.observacao != null)
              pw.Text("${c.observacao}"),

            pw.SizedBox(height: 20),

            pw.Text(
              "Medicamentos Utilizados:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 10),

            if (c.produtos.isNotEmpty)
              _buildTabelaMedicamentos(c)
            else
              pw.Text(
                "Não foi utilizado nenhum medicamento na consulta...",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
          ],
      )
    );
  }

  pw.Widget _buildTabelaMedicamentos(ConsultaDetails c) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [

        pw.TableRow(
          children: [
            _cellHeader("Produto"),
            _cellHeader("Quantidade"),
          ],
        ),

        ...c.produtos.map((p) {
          return pw.TableRow(
            children: [
              _cell(p.produto.nome),
              _cell("${p.quantidade.toString()} ${_getUnidadeMedida(p.produto.idTipoProduto)}"),
            ],
          );
        }),

      ],
    );
  }

  pw.Widget _cellHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text),
    );
  }

  String _getUnidadeMedida(int id) {
    switch (id) {
      case 1: return "ML";
      case 2: return "UND";
      default: return "N/A";
    }
  }

  String _getTipoPaciente(int id) {
    switch (id) {
      case 1: return "Aluno";
      case 2: return "Visitante";
      case 3: return "Funcionário";
      default: return "N/A";
    }
  }
}