// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectionDetail _$CollectionDetailFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CollectionDetail',
      json,
      ($checkedConvert) {
        final val = CollectionDetail(
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
          items: $checkedConvert(
            'items',
            (v) => (v as List<dynamic>?)
                ?.map((e) => Wallpaper.fromJson(e as Map<String, dynamic>))
                .toList(),
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

Map<String, dynamic> _$CollectionDetailToJson(CollectionDetail instance) =>
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
      'items': ?instance.items?.map((e) => e.toJson()).toList(),
    };
