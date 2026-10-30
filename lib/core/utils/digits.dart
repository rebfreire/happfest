/// Mantém só os dígitos — usado para CEP, CPF, telefone e números digitados
/// com máscara ou separador de milhar ("04475-300", "1.000").
String onlyDigits(String value) => value.replaceAll(RegExp('[^0-9]'), '');
