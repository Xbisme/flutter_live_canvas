# livecanvas_api.model.Wallpaper

## Load the model package
```dart
import 'package:livecanvas_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** |  | [optional] 
**title** | **String** |  | [optional] 
**category** | [**Category**](Category.md) |  | [optional] 
**tags** | [**List&lt;Tag&gt;**](Tag.md) |  | [optional] 
**orientation** | **String** |  | [optional] 
**thumbnailUrl** | **String** |  | [optional] 
**previewVideoUrl** | **String** | Video preview độ phân giải thấp, watermark nhẹ, public cho mọi wallpaper | [optional] 
**isPremium** | **bool** |  | [optional] 
**resolution** | **String** |  | [optional] 
**durationSeconds** | **num** |  | [optional] 
**fileSizeBytes** | **int** |  | [optional] 
**downloadCount** | **int** |  | [optional] 
**likeCount** | **int** |  | [optional] 
**sourceUrl** | **String** |  | [optional] 
**licenseType** | **String** |  | [optional] 
**collections** | [**List&lt;CollectionRef&gt;**](CollectionRef.md) | (Các) bộ sưu tập chứa wallpaper này — mini ref để màn Detail nhảy vào bộ. Đảm bảo populate ở GET /wallpapers/{id}; ở list lớn có thể rỗng để tiết kiệm payload.  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


