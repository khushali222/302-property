class PaymentSettingsModel {
  final bool acceptCard;
  final bool acceptACH;
  final bool acceptCash;
  final bool acceptCheck;
  final String? message;

  PaymentSettingsModel({
    this.acceptCard = false,
    this.acceptACH = false,
    this.acceptCash = false,
    this.acceptCheck = false,
    this.message,
  });

  factory PaymentSettingsModel.fromJson(Map<String, dynamic> json) {
    return PaymentSettingsModel(
      acceptCard: json['acceptCard'] ?? false,
      acceptACH: json['acceptACH'] ?? false,
      acceptCash: json['acceptCash'] ?? false,
      acceptCheck: json['acceptCheck'] ?? false,
      message: json['message'],
    );
  }

  bool get hasAnyPaymentMethod =>
      acceptCard || acceptACH || acceptCash || acceptCheck;
}
