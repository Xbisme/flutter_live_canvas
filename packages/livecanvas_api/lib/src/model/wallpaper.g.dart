// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallpaper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wallpaper _$WallpaperFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Wallpaper',
  json,
  ($checkedConvert) {
    final val = Wallpaper(
      id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
      title: $checkedConvert('title', (v) => v as String?),
      category: $checkedConvert(
        'category',
        (v) => v == null ? null : Category.fromJson(v as Map<String, dynamic>),
      ),
      tags: $checkedConvert(
        'tags',
        (v) => (v as List<dynamic>?)
            ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      orientation: $checkedConvert(
        'orientation',
        (v) => $enumDecodeNullable(_$WallpaperOrientationEnumEnumMap, v),
      ),
      thumbnailUrl: $checkedConvert('thumbnail_url', (v) => v as String?),
      previewVideoUrl: $checkedConvert(
        'preview_video_url',
        (v) => v as String?,
      ),
      isPremium: $checkedConvert('is_premium', (v) => v as bool?),
      resolution: $checkedConvert('resolution', (v) => v as String?),
      durationSeconds: $checkedConvert('duration_seconds', (v) => v as num?),
      fileSizeBytes: $checkedConvert(
        'file_size_bytes',
        (v) => (v as num?)?.toInt(),
      ),
      downloadCount: $checkedConvert(
        'download_count',
        (v) => (v as num?)?.toInt(),
      ),
      likeCount: $checkedConvert('like_count', (v) => (v as num?)?.toInt()),
      sourceUrl: $checkedConvert('source_url', (v) => v as String?),
      licenseType: $checkedConvert('license_type', (v) => v as String?),
      collections: $checkedConvert(
        'collections',
        (v) => (v as List<dynamic>?)
            ?.map((e) => CollectionRef.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'thumbnailUrl': 'thumbnail_url',
    'previewVideoUrl': 'preview_video_url',
    'isPremium': 'is_premium',
    'durationSeconds': 'duration_seconds',
    'fileSizeBytes': 'file_size_bytes',
    'downloadCount': 'download_count',
    'likeCount': 'like_count',
    'sourceUrl': 'source_url',
    'licenseType': 'license_type',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$WallpaperToJson(Wallpaper instance) => <String, dynamic>{
  'id': ?instance.id,
  'title': ?instance.title,
  'category': ?instance.category?.toJson(),
  'tags': ?instance.tags?.map((e) => e.toJson()).toList(),
  'orientation': ?_$WallpaperOrientationEnumEnumMap[instance.orientation],
  'thumbnail_url': ?instance.thumbnailUrl,
  'preview_video_url': ?instance.previewVideoUrl,
  'is_premium': ?instance.isPremium,
  'resolution': ?instance.resolution,
  'duration_seconds': ?instance.durationSeconds,
  'file_size_bytes': ?instance.fileSizeBytes,
  'download_count': ?instance.downloadCount,
  'like_count': ?instance.likeCount,
  'source_url': ?instance.sourceUrl,
  'license_type': ?instance.licenseType,
  'collections': ?instance.collections?.map((e) => e.toJson()).toList(),
  'created_at': ?instance.createdAt?.toIso8601String(),
};

const _$WallpaperOrientationEnumEnumMap = {
  WallpaperOrientationEnum.portrait: 'portrait',
  WallpaperOrientationEnum.landscape: 'landscape',
  WallpaperOrientationEnum.square: 'square',
};
