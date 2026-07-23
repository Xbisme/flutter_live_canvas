// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_wallpaper_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminWallpaperCreateRequest _$AdminWallpaperCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AdminWallpaperCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['title', 'category_id', 'orientation', 'upload_key'],
    );
    final val = AdminWallpaperCreateRequest(
      title: $checkedConvert('title', (v) => v as String),
      categoryId: $checkedConvert('category_id', (v) => (v as num).toInt()),
      tagIds: $checkedConvert(
        'tag_ids',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      orientation: $checkedConvert(
        'orientation',
        (v) =>
            $enumDecode(_$AdminWallpaperCreateRequestOrientationEnumEnumMap, v),
      ),
      isPremium: $checkedConvert('is_premium', (v) => v as bool? ?? false),
      sourceUrl: $checkedConvert('source_url', (v) => v as String?),
      licenseType: $checkedConvert('license_type', (v) => v as String?),
      uploadKey: $checkedConvert('upload_key', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'categoryId': 'category_id',
    'tagIds': 'tag_ids',
    'isPremium': 'is_premium',
    'sourceUrl': 'source_url',
    'licenseType': 'license_type',
    'uploadKey': 'upload_key',
  },
);

Map<String, dynamic> _$AdminWallpaperCreateRequestToJson(
  AdminWallpaperCreateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'category_id': instance.categoryId,
  'tag_ids': ?instance.tagIds,
  'orientation':
      _$AdminWallpaperCreateRequestOrientationEnumEnumMap[instance
          .orientation]!,
  'is_premium': ?instance.isPremium,
  'source_url': ?instance.sourceUrl,
  'license_type': ?instance.licenseType,
  'upload_key': instance.uploadKey,
};

const _$AdminWallpaperCreateRequestOrientationEnumEnumMap = {
  AdminWallpaperCreateRequestOrientationEnum.portrait: 'portrait',
  AdminWallpaperCreateRequestOrientationEnum.landscape: 'landscape',
  AdminWallpaperCreateRequestOrientationEnum.square: 'square',
};
