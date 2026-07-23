//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'collection.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Collection {
  /// Returns a new [Collection] instance.
  Collection({
    this.id,

    this.slug,

    this.title,

    this.author,

    this.description,

    this.coverUrl,

    this.accentColor,

    this.isPremium,

    this.wallpaperCount,

    this.createdAt,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'slug', required: false, includeIfNull: false)
  final String? slug;

  @JsonKey(name: r'title', required: false, includeIfNull: false)
  final String? title;

  @JsonKey(name: r'author', required: false, includeIfNull: false)
  final String? author;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'cover_url', required: false, includeIfNull: false)
  final String? coverUrl;

  /// Màu nhấn (hex) cho chrome/glow màn Collection Detail
  @JsonKey(name: r'accent_color', required: false, includeIfNull: false)
  final String? accentColor;

  @JsonKey(name: r'is_premium', required: false, includeIfNull: false)
  final bool? isPremium;

  @JsonKey(name: r'wallpaper_count', required: false, includeIfNull: false)
  final int? wallpaperCount;

  @JsonKey(name: r'created_at', required: false, includeIfNull: false)
  final DateTime? createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Collection &&
          other.id == id &&
          other.slug == slug &&
          other.title == title &&
          other.author == author &&
          other.description == description &&
          other.coverUrl == coverUrl &&
          other.accentColor == accentColor &&
          other.isPremium == isPremium &&
          other.wallpaperCount == wallpaperCount &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      id.hashCode +
      slug.hashCode +
      title.hashCode +
      author.hashCode +
      description.hashCode +
      coverUrl.hashCode +
      (accentColor == null ? 0 : accentColor.hashCode) +
      isPremium.hashCode +
      wallpaperCount.hashCode +
      createdAt.hashCode;

  factory Collection.fromJson(Map<String, dynamic> json) =>
      _$CollectionFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
