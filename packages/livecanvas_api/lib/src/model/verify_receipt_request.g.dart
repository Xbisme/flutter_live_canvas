// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_receipt_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyReceiptRequest _$VerifyReceiptRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'VerifyReceiptRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['platform', 'receipt_data', 'transaction_id'],
    );
    final val = VerifyReceiptRequest(
      platform: $checkedConvert(
        'platform',
        (v) => $enumDecode(_$VerifyReceiptRequestPlatformEnumEnumMap, v),
      ),
      receiptData: $checkedConvert('receipt_data', (v) => v as String),
      transactionId: $checkedConvert('transaction_id', (v) => v as String),
      productId: $checkedConvert('product_id', (v) => v as String?),
      deviceId: $checkedConvert('device_id', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'receiptData': 'receipt_data',
    'transactionId': 'transaction_id',
    'productId': 'product_id',
    'deviceId': 'device_id',
  },
);

Map<String, dynamic> _$VerifyReceiptRequestToJson(
  VerifyReceiptRequest instance,
) => <String, dynamic>{
  'platform': _$VerifyReceiptRequestPlatformEnumEnumMap[instance.platform]!,
  'receipt_data': instance.receiptData,
  'transaction_id': instance.transactionId,
  'product_id': ?instance.productId,
  'device_id': ?instance.deviceId,
};

const _$VerifyReceiptRequestPlatformEnumEnumMap = {
  VerifyReceiptRequestPlatformEnum.ios: 'ios',
  VerifyReceiptRequestPlatformEnum.android: 'android',
};
