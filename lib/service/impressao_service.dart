import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:projeto_enfermagem_desktop/service/config_service.dart';
import '../DTO/consulta_details.dart';

class ImpressaoService {
  final ConfigService _configService = ConfigService();

  Future<void> imprimirConsulta(ConsultaDetails consulta) async {
    final pdfBytes = await _gerarPdf(consulta);
    final nomeImpressora = await _configService.nomeImpressoraSelecionada();

    if (nomeImpressora != null) {
      try {
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
      } catch (e) {
        print("Erro ao imprimir direto: $e");
      }
    }

    // diálogo padrão caso n abra a impressora
    await Printing.layoutPdf(
      onLayout: (format) async =>
          Uint8List.fromList(pdfBytes),
    );
  }

  Future<List<int>> _gerarPdf(ConsultaDetails consulta) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildConteudo(consulta),
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildConteudo(ConsultaDetails c) {
    return pw.Column(
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
        pw.Text("Data: ${_formatarData(c.data)}"),
        pw.Text("Responsável: ${c.responsavel}"),

        pw.SizedBox(height: 20),

        pw.Text(
          "Queixa / Observações:",
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(c.demanda),

        pw.SizedBox(height: 20),

        // Medicamentos
        pw.Text(
          "Medicamentos Utilizados:",
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),

        pw.SizedBox(height: 10),

        _buildTabelaMedicamentos(c),

      ],
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
              _cell(p.quantidade.toString()),
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

  String _formatarData(DateTime data) {
    return "${data.day}/${data.month}/${data.year}";
  }
}