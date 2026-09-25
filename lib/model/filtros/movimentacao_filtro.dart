class MovimentacaoFiltro {
  MovimentacaoFiltro(
      {
        this.numeroNfe = "",
        this.situacao = "TODAS"
      });

  String? numeroNfe;
  String situacao; // TODAS, ENTRADA, SAÍDA ou CORREÇÕES
}
