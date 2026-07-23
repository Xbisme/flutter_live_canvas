//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:livecanvas_api/src/model/wallpaper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallpaper_cursor_page.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WallpaperCursorPage {
  /// Returns a new [WallpaperCursorPage] instance.
  WallpaperCursorPage({this.items, this.nextCursor, this.hasMore});

  @JsonKey(name: r'items', required: false, includeIfNull: false)
  final List<Wallpaper>? items;

  /// Truyền lại vào `cursor` để lấy trang tiếp theo. null = hết dữ liệu.
  @JsonKey(name: r'next_cursor', required: false, includeIfNull: false)
  final String? nextCursor;

  @JsonKey(name: r'has_more', required: false, includeIfNull: false)
  final bool? hasMore;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WallpaperCursorPage &&
          other.items == items &&
          other.nextCursor == nextCursor &&
          other.hasMore == hasMore;

  @override
  int get hashCode =>
      items.hashCode +
      (nextCursor == null ? 0 : nextCursor.hashCode) +
      hasMore.hashCode;

  factory WallpaperCursorPage.fromJson(Map<String, dynamic> json) =>
      _$WallpaperCursorPageFromJson(json);

  Map<String, dynamic> toJson() => _$WallpaperCursorPageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
