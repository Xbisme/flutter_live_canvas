// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apple_server_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppleServerNotification _$AppleServerNotificationFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AppleServerNotification', json, ($checkedConvert) {
  final val = AppleServerNotification(
    signedPayload: $checkedConvert('signedPayload', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AppleServerNotificationToJson(
  AppleServerNotification instance,
) => <String, dynamic>{'signedPayload': ?instance.signedPayload};
