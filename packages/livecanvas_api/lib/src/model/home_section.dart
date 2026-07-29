//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:livecanvas_api/src/model/wallpaper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'home_section.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HomeSection {
  /// Returns a new [HomeSection] instance.
  HomeSection({
    required this.key,

    required this.title,

    required this.collectionId,

    this.coverUrl,

    this.accentColor,

    required this.isPremium,

    required this.items,
  });

  /// Slug của collection. Định danh ổn định cho client (analytics/scroll-state) — đổi `title` không làm đổi `key`.
  @JsonKey(name: r'key', required: true, includeIfNull: false)
  final String key;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  /// Target của \"Xem tất cả\" → `GET /collections/{id}` (đã có).
  @JsonKey(name: r'collection_id', required: true, includeIfNull: false)
  final int collectionId;

  @JsonKey(name: r'cover_url', required: false, includeIfNull: false)
  final String? coverUrl;

  @JsonKey(name: r'accent_color', required: false, includeIfNull: false)
  final String? accentColor;

  /// CHỈ để hiển thị badge/nút \"Mở khoá\" — KHÔNG phải gate entitlement.
  @JsonKey(name: r'is_premium', required: true, includeIfNull: false)
  final bool isPremium;

  /// Tối đa 10 wallpaper published theo đúng thứ tự curate (`position`). Cùng schema Wallpaper như mọi list khác — `collections` rỗng.
  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<Wallpaper> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeSection &&
          other.key == key &&
          other.title == title &&
          other.collectionId == collectionId &&
          other.coverUrl == coverUrl &&
          other.accentColor == accentColor &&
          other.isPremium == isPremium &&
          other.items == items;

  @override
  int get hashCode =>
      key.hashCode +
      title.hashCode +
      collectionId.hashCode +
      coverUrl.hashCode +
      (accentColor == null ? 0 : accentColor.hashCode) +
      isPremium.hashCode +
      items.hashCode;

  factory HomeSection.fromJson(Map<String, dynamic> json) =>
      _$HomeSectionFromJson(json);

  Map<String, dynamic> toJson() => _$HomeSectionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
