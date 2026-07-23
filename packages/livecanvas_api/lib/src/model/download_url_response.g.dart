// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_url_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadUrlResponse _$DownloadUrlResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'DownloadUrlResponse',
      json,
      ($checkedConvert) {
        final val = DownloadUrlResponse(
          downloadUrl: $checkedConvert('download_url', (v) => v as String?),
          expiresAt: $checkedConvert(
            'expires_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'downloadUrl': 'download_url',
        'expiresAt': 'expires_at',
      },
    );

Map<String, dynamic> _$DownloadUrlResponseToJson(
  DownloadUrlResponse instance,
) => <String, dynamic>{
  'download_url': ?instance.downloadUrl,
  'expires_at': ?instance.expiresAt?.toIso8601String(),
};
