//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:livecanvas_api/src/model/home_section.dart';
import 'package:json_annotation/json_annotation.dart';

part 'home_response.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HomeResponse {
  /// Returns a new [HomeResponse] instance.
  HomeResponse({required this.sections});

  /// Tối đa 10 section, sắp theo `home_position` tăng dần (trùng vị trí → tie-break theo id, ổn định giữa các request). Chưa bật collection nào → mảng rỗng.
  @JsonKey(name: r'sections', required: true, includeIfNull: false)
  final List<HomeSection> sections;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeResponse && other.sections == sections;

  @override
  int get hashCode => sections.hashCode;

  factory HomeResponse.fromJson(Map<String, dynamic> json) =>
      _$HomeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HomeResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
