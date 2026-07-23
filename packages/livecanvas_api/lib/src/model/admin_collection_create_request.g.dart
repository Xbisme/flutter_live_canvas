// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_collection_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminCollectionCreateRequest _$AdminCollectionCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AdminCollectionCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['slug', 'title']);
    final val = AdminCollectionCreateRequest(
      slug: $checkedConvert('slug', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String),
      author: $checkedConvert('author', (v) => v as String?),
      description: $checkedConvert('description', (v) => v as String?),
      coverUploadKey: $checkedConvert('cover_upload_key', (v) => v as String?),
      accentColor: $checkedConvert('accent_color', (v) => v as String?),
      isPremium: $checkedConvert('is_premium', (v) => v as bool? ?? false),
      wallpaperIds: $checkedConvert(
        'wallpaper_ids',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'coverUploadKey': 'cover_upload_key',
    'accentColor': 'accent_color',
    'isPremium': 'is_premium',
    'wallpaperIds': 'wallpaper_ids',
  },
);

Map<String, dynamic> _$AdminCollectionCreateRequestToJson(
  AdminCollectionCreateRequest instance,
) => <String, dynamic>{
  'slug': instance.slug,
  'title': instance.title,
  'author': ?instance.author,
  'description': ?instance.description,
  'cover_upload_key': ?instance.coverUploadKey,
  'accent_color': ?instance.accentColor,
  'is_premium': ?instance.isPremium,
  'wallpaper_ids': ?instance.wallpaperIds,
};
