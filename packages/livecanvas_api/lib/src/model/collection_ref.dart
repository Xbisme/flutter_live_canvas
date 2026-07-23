//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'collection_ref.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CollectionRef {
  /// Returns a new [CollectionRef] instance.
  CollectionRef({
    this.id,

    this.slug,

    this.title,

    this.coverUrl,

    this.isPremium,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'slug', required: false, includeIfNull: false)
  final String? slug;

  @JsonKey(name: r'title', required: false, includeIfNull: false)
  final String? title;

  @JsonKey(name: r'cover_url', required: false, includeIfNull: false)
  final String? coverUrl;

  @JsonKey(name: r'is_premium', required: false, includeIfNull: false)
  final bool? isPremium;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionRef &&
          other.id == id &&
          other.slug == slug &&
          other.title == title &&
          other.coverUrl == coverUrl &&
          other.isPremium == isPremium;

  @override
  int get hashCode =>
      id.hashCode +
      slug.hashCode +
      title.hashCode +
      coverUrl.hashCode +
      isPremium.hashCode;

  factory CollectionRef.fromJson(Map<String, dynamic> json) =>
      _$CollectionRefFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionRefToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
