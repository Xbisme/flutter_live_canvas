// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionStatus _$SubscriptionStatusFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SubscriptionStatus',
      json,
      ($checkedConvert) {
        final val = SubscriptionStatus(
          transactionId: $checkedConvert('transaction_id', (v) => v as String?),
          productId: $checkedConvert('product_id', (v) => v as String?),
          status: $checkedConvert(
            'status',
            (v) =>
                $enumDecodeNullable(_$SubscriptionStatusStatusEnumEnumMap, v),
          ),
          expiresAt: $checkedConvert(
            'expires_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          autoRenew: $checkedConvert('auto_renew', (v) => v as bool?),
        );
        return val;
      },
      fieldKeyMap: const {
        'transactionId': 'transaction_id',
        'productId': 'product_id',
        'expiresAt': 'expires_at',
        'autoRenew': 'auto_renew',
      },
    );

Map<String, dynamic> _$SubscriptionStatusToJson(SubscriptionStatus instance) =>
    <String, dynamic>{
      'transaction_id': ?instance.transactionId,
      'product_id': ?instance.productId,
      'status': ?_$SubscriptionStatusStatusEnumEnumMap[instance.status],
      'expires_at': ?instance.expiresAt?.toIso8601String(),
      'auto_renew': ?instance.autoRenew,
    };

const _$SubscriptionStatusStatusEnumEnumMap = {
  SubscriptionStatusStatusEnum.active: 'active',
  SubscriptionStatusStatusEnum.expired: 'expired',
  SubscriptionStatusStatusEnum.canceled: 'canceled',
  SubscriptionStatusStatusEnum.inGracePeriod: 'in_grace_period',
  SubscriptionStatusStatusEnum.refunded: 'refunded',
};
