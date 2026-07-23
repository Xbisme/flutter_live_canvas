// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectionRef _$CollectionRefFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CollectionRef',
      json,
      ($checkedConvert) {
        final val = CollectionRef(
          id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
          slug: $checkedConvert('slug', (v) => v as String?),
          title: $checkedConvert('title', (v) => v as String?),
          coverUrl: $checkedConvert('cover_url', (v) => v as String?),
          isPremium: $checkedConvert('is_premium', (v) => v as bool?),
        );
        return val;
      },
      fieldKeyMap: const {'coverUrl': 'cover_url', 'isPremium': 'is_premium'},
    );

Map<String, dynamic> _$CollectionRefToJson(CollectionRef instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'slug': ?instance.slug,
      'title': ?instance.title,
      'cover_url': ?instance.coverUrl,
      'is_premium': ?instance.isPremium,
    };
