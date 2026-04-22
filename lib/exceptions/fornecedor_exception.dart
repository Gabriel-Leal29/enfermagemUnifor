class FornecedorException implements Exception {
  final String message;

  FornecedorException(this.message);

  @override
  String toString() => message;
}