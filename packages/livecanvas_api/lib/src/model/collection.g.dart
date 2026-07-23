// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Collection _$CollectionFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Collection',
  json,
  ($checkedConvert) {
    final val = Collection(
      id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
      slug: $checkedConvert('slug', (v) => v as String?),
      title: $checkedConvert('title', (v) => v as String?),
      author: $checkedConvert('author', (v) => v as String?),
      description: $checkedConvert('description', (v) => v as String?),
      coverUrl: $checkedConvert('cover_url', (v) => v as String?),
      accentColor: $checkedConvert('accent_color', (v) => v as String?),
      isPremium: $checkedConvert('is_premium', (v) => v as bool?),
      wallpaperCount: $checkedConvert(
        'wallpaper_count',
        (v) => (v as num?)?.toInt(),
      ),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'coverUrl': 'cover_url',
    'accentColor': 'accent_color',
    'isPremium': 'is_premium',
    'wallpaperCount': 'wallpaper_count',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$CollectionToJson(Collection instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'slug': ?instance.slug,
      'title': ?instance.title,
      'author': ?instance.author,
      'description': ?instance.description,
      'cover_url': ?instance.coverUrl,
      'accent_color': ?instance.accentColor,
      'is_premium': ?instance.isPremium,
      'wallpaper_count': ?instance.wallpaperCount,
      'created_at': ?instance.createdAt?.toIso8601String(),
    };
