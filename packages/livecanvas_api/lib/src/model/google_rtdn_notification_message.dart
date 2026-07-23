//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'google_rtdn_notification_message.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GoogleRtdnNotificationMessage {
  /// Returns a new [GoogleRtdnNotificationMessage] instance.
  GoogleRtdnNotificationMessage({this.data, this.messageId});

  @JsonKey(name: r'data', required: false, includeIfNull: false)
  final String? data;

  @JsonKey(name: r'messageId', required: false, includeIfNull: false)
  final String? messageId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoogleRtdnNotificationMessage &&
          other.data == data &&
          other.messageId == messageId;

  @override
  int get hashCode => data.hashCode + messageId.hashCode;

  factory GoogleRtdnNotificationMessage.fromJson(Map<String, dynamic> json) =>
      _$GoogleRtdnNotificationMessageFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleRtdnNotificationMessageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
