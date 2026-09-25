import 'dart:typed_data';
import 'package:flutter/material.dart'; // Necessário para a renderização do modal UI
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:projeto_enfermagem_desktop/exceptions/config_exception.dart';
import 'package:projeto_enfermagem_desktop/service/config_service.dart';
import '../DTO/consulta_details.dart';
import '../theme/theme.dart';
import '../widgets/button_amarelo_widget.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../model/config.dart';

class ImpressaoService {
  final ConfigService _configService = ConfigService();
  Config? dados;

  // estilos base dos textos do relatório
  static const pw.TextStyle _estiloTexto = pw.TextStyle(fontSize: 16);
  static final pw.TextStyle _estiloTextoNegrito = _estiloTexto.copyWith(fontWeight: pw.FontWeight.bold);

  // Recebe BuildContext para acionar o modal antes da impressão nativa
  Future imprimirConsulta(BuildContext context, ConsultaDetails consulta) async {
    try {
      dados = await _configService.buscarConfiguracoes();
      final pdfBytes = await _gerarPdf(consulta);
      final nomeImpressora = dados?.impressora;

      if (!context.mounted) return;

      // Diálogo de Validação de PDF (Telinha)
      await showDialog(
        context: context,
        builder: (dialogContext) {
          final alturaPreview = MediaQuery.of(dialogContext).size.height * 0.95;
          // Largura na proporção da folha A4, para o diálogo ficar do tamanho da página
          final larguraPreview = alturaPreview * PdfPageFormat.a4.width / PdfPageFormat.a4.height;

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias, // Recorta o cabeçalho azul nos cantos arredondados
            titlePadding: EdgeInsets.zero,
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: azulUnifor,
                border: Border(bottom: BorderSide(color: amareloUnifor, width: 3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.description_outlined, color: amareloUnifor, size: 30),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Relatório de Consulta", style: textStyleGrayTitle),
                        const SizedBox(height: 2),
                        Text(
                          "Pré-visualização · ${consulta.paciente.nome}",
                          style: textStyleSubTituloAndMenuItem,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            content: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: larguraPreview,
                height: alturaPreview,
                child: PdfPreview(
                  build: (format) async => Uint8List.fromList(pdfBytes),
                  maxPageWidth: larguraPreview,
                  allowSharing: false,
                  allowPrinting: false, // Desabilita barra de impressão genérica para utilizar regras de configuração
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  scrollViewDecoration: BoxDecoration(color: cinzaFundo),
                  pdfPreviewPageDecoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              ButtonAmareloWidget(
                texto: "Cancelar",
                isCancelamento: true,
                onPressed: () => Navigator.pop(dialogContext),
              ),
              ButtonAmareloWidget(
                texto: "Confirmar e Imprimir",
                icone: Icons.print,
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _executarEnvioImpressora(pdfBytes, nomeImpressora);
                },
              ),
            ],
          );
        },
      );

    } on ConfigException catch(e){
      print(e);
      rethrow;
    }
  }

  // Isolamento da responsabilidade de comunicação com o hardware
  Future _executarEnvioImpressora(Uint8List pdfBytes, String? nomeImpressora) async {
    if (nomeImpressora != null && nomeImpressora.isNotEmpty && nomeImpressora != "Nenhuma") {
      final printers = await _configService.listarImpressoras();

      final printer = printers.firstWhere(
            (p) => p.name == nomeImpressora,
      );

      await Printing.directPrintPdf(
        printer: printer,
        onLayout: (format) async => Uint8List.fromList(pdfBytes),
      );

      return;
    }

    // fallback de sistema operacional se a impressora local não for resolvida
    await Printing.layoutPdf(
      onLayout: (format) async => Uint8List.fromList(pdfBytes),
    );
  }

  Future _gerarPdf(ConsultaDetails c) async {
    final pdf = pw.Document();

    final bytes = await rootBundle.load('assets/images/logo_unifor_mg.jpg');
    final logoImage = pw.MemoryImage(bytes.buffer.asUint8List());

    if(dados == null){
      throw ConfigException("Preencha os dados nas configurações para realizar impressões!");
    }

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          _buildHeader(logoImage),
          pw.SizedBox(height: 30),
          ..._buildConteudo(c),
        ],
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

  // retorna a lista solta (sem Column) para o MultiPage conseguir quebrar a página entre os itens
  List<pw.Widget> _buildConteudo(ConsultaDetails c) {
    return [
      pw.Text(
        "RELATÓRIO DE CONSULTA",
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
        ),
      ),

      pw.SizedBox(height: 20),

      _campo("Paciente", c.paciente.nome),
      _campo("Tipo", _getTipoPaciente(c.paciente.idTipoPaciente)),
      if(c.paciente.matricula != null && c.paciente.matricula!.isNotEmpty)
        _campo("Matrícula", "${c.paciente.matricula}"),

      _campo("Data", c.dataFormatada),

      _campo("Responsável", c.responsavel ?? "O próprio"),

      pw.SizedBox(height: 20),

      pw.Text(
        "Queixa / Observações:",
        style: _estiloTextoNegrito,
      ),
      pw.SizedBox(height: 8),
      if(c.demanda.isNotEmpty)
        pw.Text(c.demanda, style: _estiloTexto, textAlign: pw.TextAlign.justify),

      if(c.observacao != null)
        pw.Text("${c.observacao}", style: _estiloTexto, textAlign: pw.TextAlign.justify),

      if(c.observacao == null && c.demanda.isEmpty)
        pw.Text("Nenhuma queixa ou observação inserida na consulta", style: _estiloTexto),

      pw.SizedBox(height: 20),

      pw.Text(
        "Medicamentos Utilizados:",
        style: _estiloTextoNegrito,
      ),

      pw.SizedBox(height: 10),

      if (c.produtos.isNotEmpty)
        _buildTabelaMedicamentos(c)
      else
        pw.Text(
          "Não foi utilizado nenhum medicamento na consulta...",
          style: _estiloTextoNegrito,
        ),
    ];
  }

  // label em negrito e valor normal na mesma linha, ex: "Paciente: Fulano"
  pw.Widget _campo(String label, String valor) {
    return pw.RichText(
      textAlign: pw.TextAlign.justify,
      text: pw.TextSpan(
        children: [
          pw.TextSpan(text: "$label: ", style: _estiloTextoNegrito),
          pw.TextSpan(text: valor, style: _estiloTexto),
        ],
      ),
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
        style: _estiloTextoNegrito,
      ),
    );
  }

  pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: _estiloTexto),
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
