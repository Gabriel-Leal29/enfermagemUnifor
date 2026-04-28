class ConsultaException implements Exception {
  final String message;

  ConsultaException(this.message);

  @override
  String toString() => message;
}