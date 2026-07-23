# livecanvas_api.api.AdminApi

## Load the API package
```dart
import 'package:livecanvas_api/api.dart';
```

All URIs are relative to *https://api.example.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminCollectionsGet**](AdminApi.md#admincollectionsget) | **GET** /admin/collections | Danh sách bộ sưu tập (meta + wallpaper_count, không nhúng items, không phân trang)
[**adminCollectionsIdDelete**](AdminApi.md#admincollectionsiddelete) | **DELETE** /admin/collections/{id} | Xóa bộ sưu tập (không xóa wallpaper thành viên)
[**adminCollectionsIdPatch**](AdminApi.md#admincollectionsidpatch) | **PATCH** /admin/collections/{id} | Sửa meta hoặc thêm/bớt/sắp xếp wallpaper (wallpaper_ids thay thế toàn bộ danh sách)
[**adminCollectionsPost**](AdminApi.md#admincollectionspost) | **POST** /admin/collections | Tạo bộ sưu tập — wallpaper_ids có thứ tự, phải trỏ tới wallpaper đã tồn tại
[**adminTagsGet**](AdminApi.md#admintagsget) | **GET** /admin/tags | Danh sách tag kèm wallpaper_count, để admin quyết định xóa tag nào
[**adminTagsIdDelete**](AdminApi.md#admintagsiddelete) | **DELETE** /admin/tags/{id} | Xóa tag (chặn nếu vẫn còn wallpaper đang dùng — trả 409)
[**adminTagsPost**](AdminApi.md#admintagspost) | **POST** /admin/tags | Tạo tag mới (curated — đây là cách DUY NHẤT để thêm tag)
[**adminUploadsPresignPost**](AdminApi.md#adminuploadspresignpost) | **POST** /admin/uploads/presign | 
[**adminWallpapersGet**](AdminApi.md#adminwallpapersget) | **GET** /admin/wallpapers | 
[**adminWallpapersIdDelete**](AdminApi.md#adminwallpapersiddelete) | **DELETE** /admin/wallpapers/{id} | 
[**adminWallpapersPost**](AdminApi.md#adminwallpaperspost) | **POST** /admin/wallpapers | Tạo wallpaper — tag_ids phải trỏ tới tag đã tồn tại (curated, xem /admin/tags)


# **adminCollectionsGet**
> List<Collection> adminCollectionsGet()

Danh sách bộ sưu tập (meta + wallpaper_count, không nhúng items, không phân trang)

### Example
```dart
import 'package:livecanvas_api/api.dart';

final api = LivecanvasApi().getAdminApi();

try {
    final response = api.adminCollectionsGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminCollectionsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Collection&gt;**](Collection.md)

### Authorization

[AdminBearer](../README.md#AdminBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminCollectionsIdDelete**
> adminCollectionsIdDelete(id)

Xóa bộ sưu tập (không xóa wallpaper thành viên)

### Example
```dart
import 'package:livecanvas_api/api.dart';

final api = LivecanvasApi().getAdminApi();
final int id = 56; // int | 

try {
    api.adminCollectionsIdDelete(id);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminCollectionsIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[AdminBearer](../README.md#AdminBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminCollectionsIdPatch**
> Collection adminCollectionsIdPatch(id, adminCollectionUpdateRequest)

Sửa meta hoặc thêm/bớt/sắp xếp wallpaper (wallpaper_ids thay thế toàn bộ danh sách)

### Example
```dart
import 'package:livecanvas_api/api.dart';

final api = LivecanvasApi().getAdminApi();
final int id = 56; // int | 
final AdminCollectionUpdateRequest adminCollectionUpdateRequest = ; // AdminCollectionUpdateRequest | 

try {
    final response = api.adminCollectionsIdPatch(id, adminCollectionUpdateRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminCollectionsIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **adminCollectionUpdateRequest** | [**AdminCollectionUpdateRequest**](AdminCollectionUpdateRequest.md)|  | 

### Return type

[**Collection**](Collection.md)

### Authorization

[AdminBearer](../README.md#AdminBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminCollectionsPost**
> Collection adminCollectionsPost(adminCollectionCreateRequest)

Tạo bộ sưu tập — wallpaper_ids có thứ tự, phải trỏ tới wallpaper đã tồn tại

### Example
```dart
import 'package:livecanvas_api/api.dart';

final api = LivecanvasApi().getAdminApi();
final AdminCollectionCreateRequest adminCollectionCreateRequest = ; // AdminCollectionCreateRequest | 

try {
    final response = api.adminCollectionsPost(adminCollectionCreateRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminCollectionsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminCollectionCreateRequest** | [**AdminCollectionCreateRequest**](AdminCollectionCreateRequest.md)|  | 

### Return type

[**Collection**](Collection.md)

### Authorization

[AdminBearer](../README.md#AdminBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminTagsGet**
> List<Tag> adminTagsGet()

Danh sách tag kèm wallpaper_count, để admin quyết định xóa tag nào

### Example
```dart
import 'package:livecanvas_api/api.dart';

final api = LivecanvasApi().getAdminApi();

try {
    final response = api.adminTagsGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminTagsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Tag&gt;**](Tag.md)

### Authorization

[AdminBearer](../README.md#AdminBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminTagsIdDelete**
> adminTagsIdDelete(id)

Xóa tag (chặn nếu vẫn còn wallpaper đang dùng — trả 409)

### Example
```dart
import 'package:livecanvas_api/api.dart';

final api = LivecanvasApi().getAdminApi();
final int id = 56; // int | 

try {
    api.adminTagsIdDelete(id);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminTagsIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[AdminBearer](../README.md#AdminBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminTagsPost**
> Tag adminTagsPost(adminTagCreateRequest)

Tạo tag mới (curated — đây là cách DUY NHẤT để thêm tag)

### Example
```dart
import 'package:livecanvas_api/api.dart';

final api = LivecanvasApi().getAdminApi();
final AdminTagCreateRequest adminTagCreateRequest = ; // AdminTagCreateRequest | 

try {
    final response = api.adminTagsPost(adminTagCreateRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminTagsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminTagCreateRequest** | [**AdminTagCreateRequest**](AdminTagCreateRequest.md)|  | 

### Return type

[**Tag**](Tag.md)

### Authorization

[AdminBearer](../README.md#AdminBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUploadsPresignPost**
> PresignedUploadResponse adminUploadsPresignPost(presignedUploadRequest)



### Example
```dart
import 'package:livecanvas_api/api.dart';

final api = LivecanvasApi().getAdminApi();
final PresignedUploadRequest presignedUploadRequest = ; // PresignedUploadRequest | 

try {
    final response = api.adminUploadsPresignPost(presignedUploadRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminUploadsPresignPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **presignedUploadRequest** | [**PresignedUploadRequest**](PresignedUploadRequest.md)|  | 

### Return type

[**PresignedUploadResponse**](PresignedUploadResponse.md)

### Authorization

[AdminBearer](../README.md#AdminBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminWallpapersGet**
> WallpaperCursorPage adminWallpapersGet(cursor, limit, status)



### Example
```dart
import 'package:livecanvas_api/api.dart';

final api = LivecanvasApi().getAdminApi();
final String cursor = cursor_example; // String | Opaque cursor trả về từ response trước (`next_cursor`). Bỏ trống để lấy trang đầu tiên. 
final int limit = 56; // int | 
final String status = status_example; // String | 

try {
    final response = api.adminWallpapersGet(cursor, limit, status);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminWallpapersGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| Opaque cursor trả về từ response trước (`next_cursor`). Bỏ trống để lấy trang đầu tiên.  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]
 **status** | **String**|  | [optional] 

### Return type

[**WallpaperCursorPage**](WallpaperCursorPage.md)

### Authorization

[AdminBearer](../README.md#AdminBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminWallpapersIdDelete**
> adminWallpapersIdDelete(id)



### Example
```dart
import 'package:livecanvas_api/api.dart';

final api = LivecanvasApi().getAdminApi();
final int id = 56; // int | 

try {
    api.adminWallpapersIdDelete(id);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminWallpapersIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[AdminBearer](../README.md#AdminBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminWallpapersPost**
> Wallpaper adminWallpapersPost(adminWallpaperCreateRequest)

Tạo wallpaper — tag_ids phải trỏ tới tag đã tồn tại (curated, xem /admin/tags)

### Example
```dart
import 'package:livecanvas_api/api.dart';

final api = LivecanvasApi().getAdminApi();
final AdminWallpaperCreateRequest adminWallpaperCreateRequest = ; // AdminWallpaperCreateRequest | 

try {
    final response = api.adminWallpapersPost(adminWallpaperCreateRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminWallpapersPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminWallpaperCreateRequest** | [**AdminWallpaperCreateRequest**](AdminWallpaperCreateRequest.md)|  | 

### Return type

[**Wallpaper**](Wallpaper.md)

### Authorization

[AdminBearer](../README.md#AdminBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

