class SignatureResultModel {
  final bool hasSignature;
  final double? confidence;
  final String? message;

  const SignatureResultModel({
    required this.hasSignature,
    this.confidence,
    this.message,
  });

  factory SignatureResultModel.fromJson(Map<String, dynamic> json) {
    return SignatureResultModel(
      hasSignature: json['has_signature'] as bool? ?? false,
      confidence: (json['confidence'] as num?)?.toDouble(),
      message: json['message'] as String?,
    );
  }
}
