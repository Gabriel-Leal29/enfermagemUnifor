import 'package:flutter/material.dart';
import 'package:projeto_enfermagem_desktop/exceptions/consulta_exception.dart';
import 'package:projeto_enfermagem_desktop/toast/show_toast.dart';
import 'package:projeto_enfermagem_desktop/widgets/button_amarelo_widget.dart';

import '../../DTO/consulta_details.dart';
import '../../model/paciente.dart';
import '../../service/consulta_service.dart';
import '../../theme/theme.dart';

class DialogHistoricoConsulta extends StatefulWidget {
  final Paciente paciente;

  const DialogHistoricoConsulta({super.key, required this.paciente});

  @override
  State<DialogHistoricoConsulta> createState() => _DialogHistoricoConsultaState();
}

class _DialogHistoricoConsultaState extends State<DialogHistoricoConsulta> {
  final ConsultaService _consultaService = ConsultaService();

  List<ConsultaDetails> _consultas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    try {
      final consultas = await _consultaService.listarConsultasPorPaciente(widget.paciente);

      if (!mounted) return;
      setState(() {
        _consultas = consultas;
        _carregando = false;
      });
    } on ConsultaException catch (e) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
      });
      showToast(context, message: e.message, type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 750,
        height: 700,
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
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
                      Text("Histórico de Consultas", style: textStyleBlackTituloPage),

                      const SizedBox(height: 4),

                      Text(
                        widget.paciente.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Expanded(child: _buildConteudo()),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ButtonAmareloWidget(
                            texto: "Voltar",
                            isCancelamento: true,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_consultas.isEmpty) {
      return const Center(
        child: Text(
          "Nenhuma consulta encontrada para este paciente.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      itemCount: _consultas.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildCardConsulta(_consultas[index]),
    );
  }

  Widget _buildCardConsulta(ConsultaDetails consulta) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cinzaFundo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: azulUnifor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "#${consulta.id}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.calendar_month, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                consulta.dataFormatada,
                style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildCampo("Queixa", consulta.demanda),

          if (consulta.responsavel != null && consulta.responsavel!.isNotEmpty)
            _buildCampo("Responsável", consulta.responsavel!),

          if (consulta.observacao != null && consulta.observacao!.isNotEmpty)
            _buildCampo("Observação", consulta.observacao!),

          Text(
            "Medicamentos utilizados",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade800),
          ),

          const SizedBox(height: 6),

          if (consulta.produtos.isEmpty)
            Text(
              "Nenhum medicamento utilizado.",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: consulta.produtos.map((p) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    "${p.produto.nome}  ·  ${p.quantidade}",
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCampo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 2),
          Text(valor, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
