// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presigned_upload_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PresignedUploadRequest _$PresignedUploadRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PresignedUploadRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['filename', 'content_type']);
  final val = PresignedUploadRequest(
    filename: $checkedConvert('filename', (v) => v as String),
    contentType: $checkedConvert('content_type', (v) => v as String),
  );
  return val;
}, fieldKeyMap: const {'contentType': 'content_type'});

Map<String, dynamic> _$PresignedUploadRequestToJson(
  PresignedUploadRequest instance,
) => <String, dynamic>{
  'filename': instance.filename,
  'content_type': instance.contentType,
};
