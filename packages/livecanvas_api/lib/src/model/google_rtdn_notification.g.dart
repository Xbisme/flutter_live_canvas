// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_rtdn_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleRtdnNotification _$GoogleRtdnNotificationFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GoogleRtdnNotification', json, ($checkedConvert) {
  final val = GoogleRtdnNotification(
    message: $checkedConvert(
      'message',
      (v) => v == null
          ? null
          : GoogleRtdnNotificationMessage.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$GoogleRtdnNotificationToJson(
  GoogleRtdnNotification instance,
) => <String, dynamic>{'message': ?instance.message?.toJson()};
