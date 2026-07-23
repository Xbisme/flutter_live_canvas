// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Tag', json, ($checkedConvert) {
      final val = Tag(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        slug: $checkedConvert('slug', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String?),
        wallpaperCount: $checkedConvert(
          'wallpaper_count',
          (v) => (v as num?)?.toInt(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'wallpaperCount': 'wallpaper_count'});

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
  'id': ?instance.id,
  'slug': ?instance.slug,
  'name': ?instance.name,
  'wallpaper_count': ?instance.wallpaperCount,
};
