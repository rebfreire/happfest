/// Estado/UF do IBGE — `code` é o `stateCodigoUf` esperado pela API
/// HappFest (`CustomerAddressRequest`/`PartyRequest`).
class BrazilianState {
  const BrazilianState({
    required this.code,
    required this.abbreviation,
    required this.name,
  });

  final int code;
  final String abbreviation;
  final String name;
}

/// Município do IBGE — `code` é o `cityCodigoIbge` esperado pela API
/// HappFest.
class BrazilianCity {
  const BrazilianCity({required this.code, required this.name});

  final int code;
  final String name;
}
