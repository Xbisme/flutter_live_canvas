//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:livecanvas_api/src/model/tag.dart';
import 'package:livecanvas_api/src/model/category.dart';
import 'package:livecanvas_api/src/model/collection_ref.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallpaper.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Wallpaper {
  /// Returns a new [Wallpaper] instance.
  Wallpaper({
    this.id,

    this.title,

    this.category,

    this.tags,

    this.orientation,

    this.thumbnailUrl,

    this.previewVideoUrl,

    this.isPremium,

    this.resolution,

    this.durationSeconds,

    this.fileSizeBytes,

    this.downloadCount,

    this.likeCount,

    this.sourceUrl,

    this.licenseType,

    this.collections,

    this.createdAt,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'title', required: false, includeIfNull: false)
  final String? title;

  @JsonKey(name: r'category', required: false, includeIfNull: false)
  final Category? category;

  @JsonKey(name: r'tags', required: false, includeIfNull: false)
  final List<Tag>? tags;

  @JsonKey(name: r'orientation', required: false, includeIfNull: false)
  final WallpaperOrientationEnum? orientation;

  @JsonKey(name: r'thumbnail_url', required: false, includeIfNull: false)
  final String? thumbnailUrl;

  /// Video preview độ phân giải thấp, watermark nhẹ, public cho mọi wallpaper
  @JsonKey(name: r'preview_video_url', required: false, includeIfNull: false)
  final String? previewVideoUrl;

  @JsonKey(name: r'is_premium', required: false, includeIfNull: false)
  final bool? isPremium;

  @JsonKey(name: r'resolution', required: false, includeIfNull: false)
  final String? resolution;

  @JsonKey(name: r'duration_seconds', required: false, includeIfNull: false)
  final num? durationSeconds;

  @JsonKey(name: r'file_size_bytes', required: false, includeIfNull: false)
  final int? fileSizeBytes;

  @JsonKey(name: r'download_count', required: false, includeIfNull: false)
  final int? downloadCount;

  @JsonKey(name: r'like_count', required: false, includeIfNull: false)
  final int? likeCount;

  @JsonKey(name: r'source_url', required: false, includeIfNull: false)
  final String? sourceUrl;

  @JsonKey(name: r'license_type', required: false, includeIfNull: false)
  final String? licenseType;

  /// (Các) bộ sưu tập chứa wallpaper này — mini ref để màn Detail nhảy vào bộ. Đảm bảo populate ở GET /wallpapers/{id}; ở list lớn có thể rỗng để tiết kiệm payload.
  @JsonKey(name: r'collections', required: false, includeIfNull: false)
  final List<CollectionRef>? collections;

  @JsonKey(name: r'created_at', required: false, includeIfNull: false)
  final DateTime? createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wallpaper &&
          other.id == id &&
          other.title == title &&
          other.category == category &&
          other.tags == tags &&
          other.orientation == orientation &&
          other.thumbnailUrl == thumbnailUrl &&
          other.previewVideoUrl == previewVideoUrl &&
          other.isPremium == isPremium &&
          other.resolution == resolution &&
          other.durationSeconds == durationSeconds &&
          other.fileSizeBytes == fileSizeBytes &&
          other.downloadCount == downloadCount &&
          other.likeCount == likeCount &&
          other.sourceUrl == sourceUrl &&
          other.licenseType == licenseType &&
          other.collections == collections &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      id.hashCode +
      title.hashCode +
      category.hashCode +
      tags.hashCode +
      orientation.hashCode +
      thumbnailUrl.hashCode +
      previewVideoUrl.hashCode +
      isPremium.hashCode +
      (resolution == null ? 0 : resolution.hashCode) +
      (durationSeconds == null ? 0 : durationSeconds.hashCode) +
      (fileSizeBytes == null ? 0 : fileSizeBytes.hashCode) +
      downloadCount.hashCode +
      likeCount.hashCode +
      sourceUrl.hashCode +
      licenseType.hashCode +
      collections.hashCode +
      createdAt.hashCode;

  factory Wallpaper.fromJson(Map<String, dynamic> json) =>
      _$WallpaperFromJson(json);

  Map<String, dynamic> toJson() => _$WallpaperToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum WallpaperOrientationEnum {
  @JsonValue(r'portrait')
  portrait(r'portrait'),
  @JsonValue(r'landscape')
  landscape(r'landscape'),
  @JsonValue(r'square')
  square(r'square');

  const WallpaperOrientationEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
