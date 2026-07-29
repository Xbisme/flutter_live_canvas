// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_token_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTokenResponse _$AdminTokenResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AdminTokenResponse', json, ($checkedConvert) {
      final val = AdminTokenResponse(
        access: $checkedConvert('access', (v) => v as String?),
        refresh: $checkedConvert('refresh', (v) => v as String?),
        expiresIn: $checkedConvert('expires_in', (v) => (v as num?)?.toInt()),
      );
      return val;
    }, fieldKeyMap: const {'expiresIn': 'expires_in'});

Map<String, dynamic> _$AdminTokenResponseToJson(AdminTokenResponse instance) =>
    <String, dynamic>{
      'access': ?instance.access,
      'refresh': ?instance.refresh,
      'expires_in': ?instance.expiresIn,
    };
