//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'verify_receipt_request.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerifyReceiptRequest {
  /// Returns a new [VerifyReceiptRequest] instance.
  VerifyReceiptRequest({
    required this.platform,

    required this.receiptData,

    required this.transactionId,

    this.productId,

    this.deviceId,
  });

  @JsonKey(name: r'platform', required: true, includeIfNull: false)
  final VerifyReceiptRequestPlatformEnum platform;

  @JsonKey(name: r'receipt_data', required: true, includeIfNull: false)
  final String receiptData;

  @JsonKey(name: r'transaction_id', required: true, includeIfNull: false)
  final String transactionId;

  @JsonKey(name: r'product_id', required: false, includeIfNull: false)
  final String? productId;

  @JsonKey(name: r'device_id', required: false, includeIfNull: false)
  final String? deviceId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerifyReceiptRequest &&
          other.platform == platform &&
          other.receiptData == receiptData &&
          other.transactionId == transactionId &&
          other.productId == productId &&
          other.deviceId == deviceId;

  @override
  int get hashCode =>
      platform.hashCode +
      receiptData.hashCode +
      transactionId.hashCode +
      productId.hashCode +
      deviceId.hashCode;

  factory VerifyReceiptRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyReceiptRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyReceiptRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum VerifyReceiptRequestPlatformEnum {
  @JsonValue(r'ios')
  ios(r'ios'),
  @JsonValue(r'android')
  android(r'android');

  const VerifyReceiptRequestPlatformEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
