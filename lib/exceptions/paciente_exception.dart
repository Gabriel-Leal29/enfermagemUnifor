class PacienteException implements Exception {
  final String message;

  PacienteException(this.message);

  @override
  String toString() => message;
}