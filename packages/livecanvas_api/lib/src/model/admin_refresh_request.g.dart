// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_refresh_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminRefreshRequest _$AdminRefreshRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AdminRefreshRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['refresh']);
      final val = AdminRefreshRequest(
        refresh: $checkedConvert('refresh', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AdminRefreshRequestToJson(
  AdminRefreshRequest instance,
) => <String, dynamic>{'refresh': instance.refresh};
