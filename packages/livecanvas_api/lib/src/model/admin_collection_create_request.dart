//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'admin_collection_create_request.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminCollectionCreateRequest {
  /// Returns a new [AdminCollectionCreateRequest] instance.
  AdminCollectionCreateRequest({
    required this.slug,

    required this.title,

    this.author,

    this.description,

    this.coverUploadKey,

    this.accentColor,

    this.isPremium = false,

    this.wallpaperIds,
  });

  @JsonKey(name: r'slug', required: true, includeIfNull: false)
  final String slug;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(name: r'author', required: false, includeIfNull: false)
  final String? author;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  /// upload_key ảnh cover (lấy từ POST /admin/uploads/presign)
  @JsonKey(name: r'cover_upload_key', required: false, includeIfNull: false)
  final String? coverUploadKey;

  @JsonKey(name: r'accent_color', required: false, includeIfNull: false)
  final String? accentColor;

  @JsonKey(
    defaultValue: false,
    name: r'is_premium',
    required: false,
    includeIfNull: false,
  )
  final bool? isPremium;

  /// Danh sách wallpaper có thứ tự — phải trỏ tới wallpaper đã tồn tại
  @JsonKey(name: r'wallpaper_ids', required: false, includeIfNull: false)
  final List<int>? wallpaperIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminCollectionCreateRequest &&
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
      (coverUploadKey == null ? 0 : coverUploadKey.hashCode) +
      (accentColor == null ? 0 : accentColor.hashCode) +
      isPremium.hashCode +
      wallpaperIds.hashCode;

  factory AdminCollectionCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminCollectionCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdminCollectionCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
