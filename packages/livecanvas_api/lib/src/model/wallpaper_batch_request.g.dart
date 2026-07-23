// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallpaper_batch_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WallpaperBatchRequest _$WallpaperBatchRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WallpaperBatchRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['ids']);
  final val = WallpaperBatchRequest(
    ids: $checkedConvert(
      'ids',
      (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$WallpaperBatchRequestToJson(
  WallpaperBatchRequest instance,
) => <String, dynamic>{'ids': instance.ids};
