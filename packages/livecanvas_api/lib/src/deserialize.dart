import 'package:livecanvas_api/src/model/admin_collection_create_request.dart';
import 'package:livecanvas_api/src/model/admin_collection_update_request.dart';
import 'package:livecanvas_api/src/model/admin_tag_create_request.dart';
import 'package:livecanvas_api/src/model/admin_wallpaper_create_request.dart';
import 'package:livecanvas_api/src/model/apple_server_notification.dart';
import 'package:livecanvas_api/src/model/category.dart';
import 'package:livecanvas_api/src/model/collection.dart';
import 'package:livecanvas_api/src/model/collection_detail.dart';
import 'package:livecanvas_api/src/model/collection_ref.dart';
import 'package:livecanvas_api/src/model/download_url_response.dart';
import 'package:livecanvas_api/src/model/error_response.dart';
import 'package:livecanvas_api/src/model/error_response_error.dart';
import 'package:livecanvas_api/src/model/google_rtdn_notification.dart';
import 'package:livecanvas_api/src/model/google_rtdn_notification_message.dart';
import 'package:livecanvas_api/src/model/presigned_upload_request.dart';
import 'package:livecanvas_api/src/model/presigned_upload_response.dart';
import 'package:livecanvas_api/src/model/subscription_status.dart';
import 'package:livecanvas_api/src/model/tag.dart';
import 'package:livecanvas_api/src/model/verify_receipt_request.dart';
import 'package:livecanvas_api/src/model/wallpaper.dart';
import 'package:livecanvas_api/src/model/wallpaper_batch_request.dart';
import 'package:livecanvas_api/src/model/wallpaper_cursor_page.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ReturnType deserialize<ReturnType, BaseType>(
  dynamic value,
  String targetType, {
  bool growable = true,
}) {
  switch (targetType) {
    case 'String':
      return '$value' as ReturnType;
    case 'int':
      return (value is int ? value : int.parse('$value')) as ReturnType;
    case 'bool':
      if (value is bool) {
        return value as ReturnType;
      }
      final valueString = '$value'.toLowerCase();
      return (valueString == 'true' || valueString == '1') as ReturnType;
    case 'double':
      return (value is double ? value : double.parse('$value')) as ReturnType;
    case 'AdminCollectionCreateRequest':
      return AdminCollectionCreateRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AdminCollectionUpdateRequest':
      return AdminCollectionUpdateRequest.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'AdminTagCreateRequest':
      return AdminTagCreateRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AdminWallpaperCreateRequest':
      return AdminWallpaperCreateRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AppleServerNotification':
      return AppleServerNotification.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Category':
      return Category.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Collection':
      return Collection.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'CollectionDetail':
      return CollectionDetail.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CollectionRef':
      return CollectionRef.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DownloadUrlResponse':
      return DownloadUrlResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ErrorResponse':
      return ErrorResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ErrorResponseError':
      return ErrorResponseError.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GoogleRtdnNotification':
      return GoogleRtdnNotification.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GoogleRtdnNotificationMessage':
      return GoogleRtdnNotificationMessage.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'PresignedUploadRequest':
      return PresignedUploadRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PresignedUploadResponse':
      return PresignedUploadResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SubscriptionStatus':
      return SubscriptionStatus.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Tag':
      return Tag.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'VerifyReceiptRequest':
      return VerifyReceiptRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Wallpaper':
      return Wallpaper.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'WallpaperBatchRequest':
      return WallpaperBatchRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WallpaperCursorPage':
      return WallpaperCursorPage.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    default:
      RegExpMatch? match;

      if (value is List && (match = _regList.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toList(growable: growable)
            as ReturnType;
      }
      if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toSet()
            as ReturnType;
      }
      if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
        targetType = match![1]!.trim(); // ignore: parameter_assignments
        return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map(
                (dynamic v) => deserialize<BaseType, BaseType>(
                  v,
                  targetType,
                  growable: growable,
                ),
              ),
            )
            as ReturnType;
      }
      break;
  }
  throw Exception('Cannot deserialize');
}
