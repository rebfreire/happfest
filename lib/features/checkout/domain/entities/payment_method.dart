enum PaymentMethod { pix, creditCard, boleto }

extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.pix => 'Pix',
    PaymentMethod.creditCard => 'Cartão de crédito',
    PaymentMethod.boleto => 'Boleto',
  };

  String get apiValue => switch (this) {
    PaymentMethod.pix => 'PIX',
    PaymentMethod.creditCard => 'CREDIT_CARD',
    PaymentMethod.boleto => 'BOLETO',
  };
}
