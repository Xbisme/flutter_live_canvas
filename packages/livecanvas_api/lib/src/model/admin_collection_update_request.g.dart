// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_collection_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminCollectionUpdateRequest _$AdminCollectionUpdateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AdminCollectionUpdateRequest',
  json,
  ($checkedConvert) {
    final val = AdminCollectionUpdateRequest(
      slug: $checkedConvert('slug', (v) => v as String?),
      title: $checkedConvert('title', (v) => v as String?),
      author: $checkedConvert('author', (v) => v as String?),
      description: $checkedConvert('description', (v) => v as String?),
      coverUploadKey: $checkedConvert('cover_upload_key', (v) => v as String?),
      accentColor: $checkedConvert('accent_color', (v) => v as String?),
      isPremium: $checkedConvert('is_premium', (v) => v as bool?),
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

Map<String, dynamic> _$AdminCollectionUpdateRequestToJson(
  AdminCollectionUpdateRequest instance,
) => <String, dynamic>{
  'slug': ?instance.slug,
  'title': ?instance.title,
  'author': ?instance.author,
  'description': ?instance.description,
  'cover_upload_key': ?instance.coverUploadKey,
  'accent_color': ?instance.accentColor,
  'is_premium': ?instance.isPremium,
  'wallpaper_ids': ?instance.wallpaperIds,
};
