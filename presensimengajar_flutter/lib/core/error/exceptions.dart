class AppExceptions implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? response;

  AppExceptions(this.message, {this.statusCode, this.response});

  @override
  String toString() => message;
}

class AuthException extends AppExceptions {
  AuthException(super.message, {super.statusCode, super.response});
}

class ServerException extends AppExceptions {
  ServerException(super.message, {super.statusCode, super.response});
}

class NetworkException extends AppExceptions {
  NetworkException(super.message);
}
