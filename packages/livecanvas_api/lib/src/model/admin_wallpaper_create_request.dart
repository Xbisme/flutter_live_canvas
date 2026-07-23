//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'admin_wallpaper_create_request.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminWallpaperCreateRequest {
  /// Returns a new [AdminWallpaperCreateRequest] instance.
  AdminWallpaperCreateRequest({
    required this.title,

    required this.categoryId,

    this.tagIds,

    required this.orientation,

    this.isPremium = false,

    this.sourceUrl,

    this.licenseType,

    required this.uploadKey,
  });

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(name: r'category_id', required: true, includeIfNull: false)
  final int categoryId;

  /// Curated — phải là ID tag đã tồn tại, tạo tag mới qua /admin/tags trước
  @JsonKey(name: r'tag_ids', required: false, includeIfNull: false)
  final List<int>? tagIds;

  @JsonKey(name: r'orientation', required: true, includeIfNull: false)
  final AdminWallpaperCreateRequestOrientationEnum orientation;

  @JsonKey(
    defaultValue: false,
    name: r'is_premium',
    required: false,
    includeIfNull: false,
  )
  final bool? isPremium;

  @JsonKey(name: r'source_url', required: false, includeIfNull: false)
  final String? sourceUrl;

  @JsonKey(name: r'license_type', required: false, includeIfNull: false)
  final String? licenseType;

  @JsonKey(name: r'upload_key', required: true, includeIfNull: false)
  final String uploadKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminWallpaperCreateRequest &&
          other.title == title &&
          other.categoryId == categoryId &&
          other.tagIds == tagIds &&
          other.orientation == orientation &&
          other.isPremium == isPremium &&
          other.sourceUrl == sourceUrl &&
          other.licenseType == licenseType &&
          other.uploadKey == uploadKey;

  @override
  int get hashCode =>
      title.hashCode +
      categoryId.hashCode +
      tagIds.hashCode +
      orientation.hashCode +
      isPremium.hashCode +
      sourceUrl.hashCode +
      licenseType.hashCode +
      uploadKey.hashCode;

  factory AdminWallpaperCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminWallpaperCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdminWallpaperCreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AdminWallpaperCreateRequestOrientationEnum {
  @JsonValue(r'portrait')
  portrait(r'portrait'),
  @JsonValue(r'landscape')
  landscape(r'landscape'),
  @JsonValue(r'square')
  square(r'square');

  const AdminWallpaperCreateRequestOrientationEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
