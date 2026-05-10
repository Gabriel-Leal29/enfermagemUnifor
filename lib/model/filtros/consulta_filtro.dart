class ConsultaFiltro {
  ConsultaFiltro(
      {
        this.nomePaciente = "",
        this.dataInicial,
        this.dataFinal
      });

  String? nomePaciente;
  DateTime? dataInicial;
  DateTime? dataFinal;
}