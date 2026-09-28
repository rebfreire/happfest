sealed class Failure {
  const Failure(this.message);

  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Sessão expirada.']);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Você não tem permissão para isso.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Não encontrado.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(this.fields, [super.message = 'Dados inválidos.']);

  final Map<String, List<String>> fields;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erro no servidor. Tente novamente.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Algo deu errado. Tente novamente.']);
}
