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
**showOnHome** | **bool** | (v0.7.0) Cho collection này hiện thành section ở màn Browse (`GET /home`). Mặc định tắt. Bật quá 10 collection vẫn hợp lệ — trần chỉ áp lúc đọc.  | [optional] [default to false]
**homePosition** | **int** | (v0.7.0) Vị trí section trên Browse, tăng dần. KHÔNG unique — trùng vị trí thì tie-break theo id. Vô nghĩa khi `show_on_home=false`.  | [optional] [default to 0]
**wallpaperIds** | **List&lt;int&gt;** | Danh sách wallpaper có thứ tự — phải trỏ tới wallpaper đã tồn tại | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


