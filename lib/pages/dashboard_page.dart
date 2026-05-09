import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../dao/consulta_dao.dart';
import '../dao/paciente_dao.dart';
import '../dao/produto_dao.dart';
import '../theme/theme.dart';
import '../bases/page_base.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _consultaDao = ConsultaDao();
  final _pacienteDao = PacienteDao();
  final _produtoDao = ProdutoDao();

  bool _isLoading = true;
  
  int atendimentosHoje = 0;
  int totalPacientes = 0;
  String diaDePico = '-';
  double mediaSemanal = 0.0;
  
  int totalProdutos = 0;
  int estoqueNormal = 0;
  int estoqueBaixo = 0;
  int semEstoque = 0;
  
  List<BarChartGroupData> barGroups = [];
  List<PieChartSectionData> pieSections = [];
  List<PieChartSectionData> pieEstoqueSections = [];
  List<FlSpot> lineSpots = [];
  List<String> dias7Labels = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);

    try {
      atendimentosHoje = await _consultaDao.getAtendimentosHoje();
      totalPacientes = await _pacienteDao.getTotalPacientes();
      
      final tipoPacientes = await _pacienteDao.getPacientesPorTipo();
      _buildPieChart(tipoPacientes);

      // Simulando processamento dos últimos 7 dias para barras e médias
      final consultas7Dias = await _consultaDao.getAtendimentosUltimosDias(7);
      _processarConsultas7Dias(consultas7Dias);

      // Simulando processamento dos últimos 30 dias para a linha de evolução
      final consultas30Dias = await _consultaDao.getAtendimentosUltimosDias(30);
      _processarConsultas30Dias(consultas30Dias);

      final statsEstoque = await _produtoDao.getEstatisticasEstoque(10.0);
      totalProdutos = statsEstoque['total'] ?? 0;
      estoqueNormal = statsEstoque['normal'] ?? 0;
      estoqueBaixo = statsEstoque['baixo'] ?? 0;
      semEstoque = statsEstoque['zerado'] ?? 0;
      _buildPieEstoqueChart();
    } catch (e) {
      print("Erro ao carregar dashboard: \$e");
    }

    setState(() => _isLoading = false);
  }

  void _buildPieChart(List<Map<String, dynamic>> dados) {
    pieSections = [];
    final colors = [azulUnifor, amareloUnifor, Colors.lightBlue];
    int i = 0;
    
    for (var d in dados) {
      final total = d['total'] as int? ?? 0;
      final tipo = d['tipo'] as String? ?? 'Desconhecido';
      
      if (total > 0) {
        pieSections.add(
          PieChartSectionData(
            color: colors[i % colors.length],
            value: total.toDouble(),
            title: '$total',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          )
        );
      }
      i++;
    }
  }

  void _buildPieEstoqueChart() {
    pieEstoqueSections = [];
    if (totalProdutos == 0) return;
    
    if (estoqueNormal > 0) {
      pieEstoqueSections.add(PieChartSectionData(color: Colors.green, value: estoqueNormal.toDouble(), title: '$estoqueNormal', radius: 50, titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)));
    }
    if (estoqueBaixo > 0) {
      pieEstoqueSections.add(PieChartSectionData(color: Colors.orange, value: estoqueBaixo.toDouble(), title: '$estoqueBaixo', radius: 50, titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)));
    }
    if (semEstoque > 0) {
      pieEstoqueSections.add(PieChartSectionData(color: Colors.red, value: semEstoque.toDouble(), title: '$semEstoque', radius: 50, titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)));
    }
  }

  void _processarConsultas7Dias(List<Map<String, dynamic>> consultas) {
    barGroups = [];
    dias7Labels = [];
    int maxCount = 0;
    int maxDayIndex = -1;

    final hoje = DateTime.now();
    List<DateTime> ultimos7Dias = [];
    for (int i = 6; i >= 0; i--) {
      ultimos7Dias.add(hoje.subtract(Duration(days: i)));
    }

    Map<String, int> contagem = {};
    for (var d in ultimos7Dias) {
      String chave = DateFormat('dd/MM').format(d);
      contagem[chave] = 0;
      dias7Labels.add(chave);
    }

    int totalSemana = 0;
    for (var c in consultas) {
      final dataMs = c['data'] as int?;
      if (dataMs != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(dataMs);
        String chave = DateFormat('dd/MM').format(dt);
        if (contagem.containsKey(chave)) {
          contagem[chave] = contagem[chave]! + 1;
          totalSemana++;
        }
      }
    }

    mediaSemanal = totalSemana / 7.0;

    for (int i = 0; i < 7; i++) {
      String chave = dias7Labels[i];
      int count = contagem[chave]!;
      if (count > maxCount) {
        maxCount = count;
        maxDayIndex = i;
      }
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: azulUnifor,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            )
          ],
        )
      );
    }

    diaDePico = maxDayIndex != -1 ? dias7Labels[maxDayIndex] : '-';
  }

  void _processarConsultas30Dias(List<Map<String, dynamic>> consultas) {
    Map<int, int> contagemSemanas = {0:0, 1:0, 2:0, 3:0};
    
    final hoje = DateTime.now();
    for(var c in consultas) {
      final dataMs = c['data'] as int?;
      if(dataMs != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(dataMs);
        final diasAtras = hoje.difference(dt).inDays;
        
        if (diasAtras < 0) continue; 
        
        if (diasAtras < 7) {
            contagemSemanas[3] = (contagemSemanas[3] ?? 0) + 1; 
        } else if (diasAtras < 14) {
            contagemSemanas[2] = (contagemSemanas[2] ?? 0) + 1; 
        } else if (diasAtras < 21) {
            contagemSemanas[1] = (contagemSemanas[1] ?? 0) + 1; 
        } else if (diasAtras < 30) {
            contagemSemanas[0] = (contagemSemanas[0] ?? 0) + 1; 
        }
      }
    }
    
    lineSpots = [
      FlSpot(1, (contagemSemanas[0] ?? 0).toDouble()),
      FlSpot(2, (contagemSemanas[1] ?? 0).toDouble()),
      FlSpot(3, (contagemSemanas[2] ?? 0).toDouble()),
      FlSpot(4, (contagemSemanas[3] ?? 0).toDouble()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PageBase(
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildBarChartCard()),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: _buildPieChartCard()),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildLineChartCard()),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: _buildPieEstoqueCard()),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dashboard", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Visão geral dos atendimentos de enfermagem", style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
              SizedBox(width: 8),
              Text("Sistema Ativo", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard("ATENDIMENTOS HOJE", atendimentosHoje.toString(), Icons.medical_services_outlined, azulUnifor)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard("TOTAL DE PACIENTES", totalPacientes.toString(), Icons.people_outline, amareloUnifor)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard("DIA DE PICO", diaDePico, Icons.calendar_today_outlined, Colors.lightBlue)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard("MÉDIA SEMANAL", mediaSemanal.toStringAsFixed(1), Icons.trending_up, Colors.green)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Atendimentos por Dia", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 25,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < dias7Labels.length) {
                          return Text(dias7Labels[index], style: TextStyle(color: Colors.grey[600], fontSize: 11));
                        }
                        return const Text('');
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 6),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 6,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200], strokeWidth: 1, dashArray: [5, 5]),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Por Tipo de Paciente", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: pieSections.isEmpty 
                    ? [PieChartSectionData(color: Colors.grey[300], value: 1, radius: 50, showTitle: false)] 
                    : pieSections,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(azulUnifor, "Alunos"),
              const SizedBox(width: 16),
              _buildLegendItem(amareloUnifor, "Funcionários"),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.lightBlue, "Visitantes"),
            ],
          )
        ],
      ),
    );
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildLineChartCard() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Evolução Mensal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200], strokeWidth: 1, dashArray: [5, 5]),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text('Sem \${value.toInt()}', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 20),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: 4,
                minY: 0,
                maxY: 80,
                lineBarsData: [
                  LineChartBarData(
                    spots: lineSpots,
                    isCurved: true,
                    color: amareloUnifor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: amareloUnifor.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieEstoqueCard() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Saúde do Estoque", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: pieEstoqueSections.isEmpty 
                    ? [PieChartSectionData(color: Colors.grey[300], value: 1, radius: 40, showTitle: false)] 
                    : pieEstoqueSections,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.green, "Normal"),
              const SizedBox(width: 8),
              _buildLegendItem(Colors.orange, "Baixo"),
              const SizedBox(width: 8),
              _buildLegendItem(Colors.red, "Zerado"),
            ],
          )
        ],
      ),
    );
  }
}
