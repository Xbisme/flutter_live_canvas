//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'subscription_status.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SubscriptionStatus {
  /// Returns a new [SubscriptionStatus] instance.
  SubscriptionStatus({
    this.transactionId,

    this.productId,

    this.status,

    this.expiresAt,

    this.autoRenew,
  });

  @JsonKey(name: r'transaction_id', required: false, includeIfNull: false)
  final String? transactionId;

  @JsonKey(name: r'product_id', required: false, includeIfNull: false)
  final String? productId;

  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final SubscriptionStatusStatusEnum? status;

  @JsonKey(name: r'expires_at', required: false, includeIfNull: false)
  final DateTime? expiresAt;

  @JsonKey(name: r'auto_renew', required: false, includeIfNull: false)
  final bool? autoRenew;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionStatus &&
          other.transactionId == transactionId &&
          other.productId == productId &&
          other.status == status &&
          other.expiresAt == expiresAt &&
          other.autoRenew == autoRenew;

  @override
  int get hashCode =>
      transactionId.hashCode +
      productId.hashCode +
      status.hashCode +
      (expiresAt == null ? 0 : expiresAt.hashCode) +
      autoRenew.hashCode;

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionStatusToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum SubscriptionStatusStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'expired')
  expired(r'expired'),
  @JsonValue(r'canceled')
  canceled(r'canceled'),
  @JsonValue(r'in_grace_period')
  inGracePeriod(r'in_grace_period'),
  @JsonValue(r'refunded')
  refunded(r'refunded');

  const SubscriptionStatusStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
