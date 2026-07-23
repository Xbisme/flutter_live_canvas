//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'wallpaper_batch_request.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WallpaperBatchRequest {
  /// Returns a new [WallpaperBatchRequest] instance.
  WallpaperBatchRequest({required this.ids});

  /// Tối đa 100 ID mỗi lần gọi
  @JsonKey(name: r'ids', required: true, includeIfNull: false)
  final List<int> ids;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WallpaperBatchRequest && other.ids == ids;

  @override
  int get hashCode => ids.hashCode;

  factory WallpaperBatchRequest.fromJson(Map<String, dynamic> json) =>
      _$WallpaperBatchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WallpaperBatchRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
