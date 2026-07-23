// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_rtdn_notification_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleRtdnNotificationMessage _$GoogleRtdnNotificationMessageFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GoogleRtdnNotificationMessage', json, ($checkedConvert) {
  final val = GoogleRtdnNotificationMessage(
    data: $checkedConvert('data', (v) => v as String?),
    messageId: $checkedConvert('messageId', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$GoogleRtdnNotificationMessageToJson(
  GoogleRtdnNotificationMessage instance,
) => <String, dynamic>{
  'data': ?instance.data,
  'messageId': ?instance.messageId,
};
