//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Tag {
  /// Returns a new [Tag] instance.
  Tag({this.id, this.slug, this.name, this.wallpaperCount});

  /// 0 = tag ảo \"All\" (reserved); tag thật ≥ 1
  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  /// \"all\" là slug reserved cho tag ảo
  @JsonKey(name: r'slug', required: false, includeIfNull: false)
  final String? slug;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'wallpaper_count', required: false, includeIfNull: false)
  final int? wallpaperCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag &&
          other.id == id &&
          other.slug == slug &&
          other.name == name &&
          other.wallpaperCount == wallpaperCount;

  @override
  int get hashCode =>
      id.hashCode + slug.hashCode + name.hashCode + wallpaperCount.hashCode;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
