//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'admin_collection_update_request.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminCollectionUpdateRequest {
  /// Returns a new [AdminCollectionUpdateRequest] instance.
  AdminCollectionUpdateRequest({
    this.slug,

    this.title,

    this.author,

    this.description,

    this.coverUploadKey,

    this.accentColor,

    this.isPremium,

    this.wallpaperIds,
  });

  @JsonKey(name: r'slug', required: false, includeIfNull: false)
  final String? slug;

  @JsonKey(name: r'title', required: false, includeIfNull: false)
  final String? title;

  @JsonKey(name: r'author', required: false, includeIfNull: false)
  final String? author;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'cover_upload_key', required: false, includeIfNull: false)
  final String? coverUploadKey;

  @JsonKey(name: r'accent_color', required: false, includeIfNull: false)
  final String? accentColor;

  @JsonKey(name: r'is_premium', required: false, includeIfNull: false)
  final bool? isPremium;

  @JsonKey(name: r'wallpaper_ids', required: false, includeIfNull: false)
  final List<int>? wallpaperIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminCollectionUpdateRequest &&
          other.slug == slug &&
          other.title == title &&
          other.author == author &&
          other.description == description &&
          other.coverUploadKey == coverUploadKey &&
          other.accentColor == accentColor &&
          other.isPremium == isPremium &&
          other.wallpaperIds == wallpaperIds;

  @override
  int get hashCode =>
      slug.hashCode +
      title.hashCode +
      author.hashCode +
      description.hashCode +
      coverUploadKey.hashCode +
      (accentColor == null ? 0 : accentColor.hashCode) +
      isPremium.hashCode +
      wallpaperIds.hashCode;

  factory AdminCollectionUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminCollectionUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdminCollectionUpdateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
