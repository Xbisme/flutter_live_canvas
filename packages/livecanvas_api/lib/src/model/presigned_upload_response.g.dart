// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presigned_upload_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PresignedUploadResponse _$PresignedUploadResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PresignedUploadResponse',
  json,
  ($checkedConvert) {
    final val = PresignedUploadResponse(
      uploadUrl: $checkedConvert('upload_url', (v) => v as String?),
      uploadKey: $checkedConvert('upload_key', (v) => v as String?),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'uploadUrl': 'upload_url',
    'uploadKey': 'upload_key',
    'expiresAt': 'expires_at',
  },
);

Map<String, dynamic> _$PresignedUploadResponseToJson(
  PresignedUploadResponse instance,
) => <String, dynamic>{
  'upload_url': ?instance.uploadUrl,
  'upload_key': ?instance.uploadKey,
  'expires_at': ?instance.expiresAt?.toIso8601String(),
};
