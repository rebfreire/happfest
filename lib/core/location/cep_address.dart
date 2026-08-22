/// Endereço resolvido a partir de um CEP via ViaCEP — `cityCodigoIbge` já
/// vem pronto (`ibge` na resposta) e `stateCodigoUf` é derivado dos 2
/// primeiros dígitos dele, evitando o picker manual de estado/cidade no
/// caminho feliz (usuário só digita o CEP).
class CepAddress {
  const CepAddress({
    required this.street,
    required this.neighborhood,
    required this.cityName,
    required this.stateAbbreviation,
    required this.cityCodigoIbge,
    required this.stateCodigoUf,
  });

  final String street;
  final String neighborhood;
  final String cityName;
  final String stateAbbreviation;
  final int cityCodigoIbge;
  final int stateCodigoUf;
}
