// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeSection _$HomeSectionFromJson(Map<String, dynamic> json) => $checkedCreate(
  'HomeSection',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'key',
        'title',
        'collection_id',
        'is_premium',
        'items',
      ],
    );
    final val = HomeSection(
      key: $checkedConvert('key', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String),
      collectionId: $checkedConvert('collection_id', (v) => (v as num).toInt()),
      coverUrl: $checkedConvert('cover_url', (v) => v as String?),
      accentColor: $checkedConvert('accent_color', (v) => v as String?),
      isPremium: $checkedConvert('is_premium', (v) => v as bool),
      items: $checkedConvert(
        'items',
        (v) => (v as List<dynamic>)
            .map((e) => Wallpaper.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'collectionId': 'collection_id',
    'coverUrl': 'cover_url',
    'accentColor': 'accent_color',
    'isPremium': 'is_premium',
  },
);

Map<String, dynamic> _$HomeSectionToJson(HomeSection instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'collection_id': instance.collectionId,
      'cover_url': ?instance.coverUrl,
      'accent_color': ?instance.accentColor,
      'is_premium': instance.isPremium,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
