// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Category',
  json,
  ($checkedConvert) {
    final val = Category(
      id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
      slug: $checkedConvert('slug', (v) => v as String?),
      name: $checkedConvert('name', (v) => v as String?),
      iconUrl: $checkedConvert('icon_url', (v) => v as String?),
      wallpaperCount: $checkedConvert(
        'wallpaper_count',
        (v) => (v as num?)?.toInt(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'iconUrl': 'icon_url',
    'wallpaperCount': 'wallpaper_count',
  },
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': ?instance.id,
  'slug': ?instance.slug,
  'name': ?instance.name,
  'icon_url': ?instance.iconUrl,
  'wallpaper_count': ?instance.wallpaperCount,
};
