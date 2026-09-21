class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.network() =>
      const ApiException('Could not reach the server. Check your connection.');

  factory ApiException.timeout() =>
      const ApiException('The request timed out. Please try again.');

  factory ApiException.server(int statusCode, [String? message]) =>
      ApiException(message ?? 'Server error.', statusCode: statusCode);

  factory ApiException.unknown([String? message]) =>
      ApiException(message ?? 'Something went wrong.');

  @override
  String toString() => message;
}
