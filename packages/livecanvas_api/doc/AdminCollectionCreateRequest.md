# livecanvas_api.model.AdminCollectionCreateRequest

## Load the model package
```dart
import 'package:livecanvas_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**slug** | **String** |  | 
**title** | **String** |  | 
**author** | **String** |  | [optional] 
**description** | **String** |  | [optional] 
**coverUploadKey** | **String** | upload_key ảnh cover (lấy từ POST /admin/uploads/presign) | [optional] 
**accentColor** | **String** |  | [optional] 
**isPremium** | **bool** |  | [optional] [default to false]
**wallpaperIds** | **List&lt;int&gt;** | Danh sách wallpaper có thứ tự — phải trỏ tới wallpaper đã tồn tại | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


