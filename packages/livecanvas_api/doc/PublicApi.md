# livecanvas_api.api.PublicApi

## Load the API package
```dart
import 'package:livecanvas_api/api.dart';
```

All URIs are relative to *https://api.example.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**categoriesGet**](PublicApi.md#categoriesget) | **GET** /categories | Danh sách category (không phân trang — số lượng nhỏ, admin curate)
[**collectionsGet**](PublicApi.md#collectionsget) | **GET** /collections | Danh sách bộ sưu tập curated (không phân trang — chỉ meta, không nhúng items)
[**collectionsIdGet**](PublicApi.md#collectionsidget) | **GET** /collections/{id} | Chi tiết 1 bộ sưu tập + danh sách wallpaper thành viên (đúng thứ tự, không phân trang)
[**tagsGet**](PublicApi.md#tagsget) | **GET** /tags | Danh sách tag curated (không phân trang — dùng cho filter chips + admin chọn)
[**wallpapersBatchPost**](PublicApi.md#wallpapersbatchpost) | **POST** /wallpapers/batch | Lấy lại data mới nhất cho nhiều wallpaper theo ID (dùng cho màn Favorites)
[**wallpapersGet**](PublicApi.md#wallpapersget) | **GET** /wallpapers | Danh sách wallpaper — cursor pagination, filter category/tags/orientation/search
[**wallpapersIdDownloadUrlGet**](PublicApi.md#wallpapersiddownloadurlget) | **GET** /wallpapers/{id}/download-url | 
[**wallpapersIdGet**](PublicApi.md#wallpapersidget) | **GET** /wallpapers/{id} | 


# **categoriesGet**
> List<Category> categoriesGet()

Danh sách category (không phân trang — số lượng nhỏ, admin curate)

### Example
```dart
import 'package:livecanvas_api/api.dart';
// TODO Configure API key authorization: AppApiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKeyPrefix = 'Bearer';

final api = LivecanvasApi().getPublicApi();

try {
    final response = api.categoriesGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PublicApi->categoriesGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Category&gt;**](Category.md)

### Authorization

[AppApiKey](../README.md#AppApiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **collectionsGet**
> List<Collection> collectionsGet()

Danh sách bộ sưu tập curated (không phân trang — chỉ meta, không nhúng items)

### Example
```dart
import 'package:livecanvas_api/api.dart';
// TODO Configure API key authorization: AppApiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKeyPrefix = 'Bearer';

final api = LivecanvasApi().getPublicApi();

try {
    final response = api.collectionsGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PublicApi->collectionsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Collection&gt;**](Collection.md)

### Authorization

[AppApiKey](../README.md#AppApiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **collectionsIdGet**
> CollectionDetail collectionsIdGet(id)

Chi tiết 1 bộ sưu tập + danh sách wallpaper thành viên (đúng thứ tự, không phân trang)

### Example
```dart
import 'package:livecanvas_api/api.dart';
// TODO Configure API key authorization: AppApiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKeyPrefix = 'Bearer';

final api = LivecanvasApi().getPublicApi();
final int id = 56; // int | 

try {
    final response = api.collectionsIdGet(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PublicApi->collectionsIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**CollectionDetail**](CollectionDetail.md)

### Authorization

[AppApiKey](../README.md#AppApiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tagsGet**
> List<Tag> tagsGet()

Danh sách tag curated (không phân trang — dùng cho filter chips + admin chọn)

Trả toàn bộ tag curated. Phần tử ĐẦU TIÊN luôn là tag ảo \"Tất cả\" (id=0, slug=\"all\", wallpaper_count = tổng wallpaper published) do API sinh — không lưu DB. Client render nó làm chip mặc định; chọn nó = gọi GET /wallpapers không truyền `tags`. 

### Example
```dart
import 'package:livecanvas_api/api.dart';
// TODO Configure API key authorization: AppApiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKeyPrefix = 'Bearer';

final api = LivecanvasApi().getPublicApi();

try {
    final response = api.tagsGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PublicApi->tagsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Tag&gt;**](Tag.md)

### Authorization

[AppApiKey](../README.md#AppApiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **wallpapersBatchPost**
> List<Wallpaper> wallpapersBatchPost(wallpaperBatchRequest)

Lấy lại data mới nhất cho nhiều wallpaper theo ID (dùng cho màn Favorites)

### Example
```dart
import 'package:livecanvas_api/api.dart';
// TODO Configure API key authorization: AppApiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKeyPrefix = 'Bearer';

final api = LivecanvasApi().getPublicApi();
final WallpaperBatchRequest wallpaperBatchRequest = ; // WallpaperBatchRequest | 

try {
    final response = api.wallpapersBatchPost(wallpaperBatchRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PublicApi->wallpapersBatchPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **wallpaperBatchRequest** | [**WallpaperBatchRequest**](WallpaperBatchRequest.md)|  | 

### Return type

[**List&lt;Wallpaper&gt;**](Wallpaper.md)

### Authorization

[AppApiKey](../README.md#AppApiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **wallpapersGet**
> WallpaperCursorPage wallpapersGet(cursor, limit, category, tags, orientation, search, isPremium)

Danh sách wallpaper — cursor pagination, filter category/tags/orientation/search

### Example
```dart
import 'package:livecanvas_api/api.dart';
// TODO Configure API key authorization: AppApiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKeyPrefix = 'Bearer';

final api = LivecanvasApi().getPublicApi();
final String cursor = cursor_example; // String | Opaque cursor trả về từ response trước (`next_cursor`). Bỏ trống để lấy trang đầu tiên. 
final int limit = 56; // int | 
final String category = category_example; // String | Slug category để lọc
final String tags = tags_example; // String | Danh sách slug tag, phân tách bằng dấu phẩy (vd \"neon,night\"). Kết quả phải khớp TẤT CẢ tag được liệt kê (AND, không phải OR). Slug reserved \"all\" (tag ảo \"Tất cả\") bị BỎ QUA — coi như không ràng buộc tag; vd \"all\" → toàn bộ, \"all,neon\" → chỉ lọc \"neon\". 
final String orientation = orientation_example; // String | 
final String search = search_example; // String | 
final bool isPremium = true; // bool | 

try {
    final response = api.wallpapersGet(cursor, limit, category, tags, orientation, search, isPremium);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PublicApi->wallpapersGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| Opaque cursor trả về từ response trước (`next_cursor`). Bỏ trống để lấy trang đầu tiên.  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]
 **category** | **String**| Slug category để lọc | [optional] 
 **tags** | **String**| Danh sách slug tag, phân tách bằng dấu phẩy (vd \"neon,night\"). Kết quả phải khớp TẤT CẢ tag được liệt kê (AND, không phải OR). Slug reserved \"all\" (tag ảo \"Tất cả\") bị BỎ QUA — coi như không ràng buộc tag; vd \"all\" → toàn bộ, \"all,neon\" → chỉ lọc \"neon\".  | [optional] 
 **orientation** | **String**|  | [optional] 
 **search** | **String**|  | [optional] 
 **isPremium** | **bool**|  | [optional] 

### Return type

[**WallpaperCursorPage**](WallpaperCursorPage.md)

### Authorization

[AppApiKey](../README.md#AppApiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **wallpapersIdDownloadUrlGet**
> DownloadUrlResponse wallpapersIdDownloadUrlGet(id, transactionId)



### Example
```dart
import 'package:livecanvas_api/api.dart';
// TODO Configure API key authorization: AppApiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKeyPrefix = 'Bearer';

final api = LivecanvasApi().getPublicApi();
final int id = 56; // int | 
final String transactionId = transactionId_example; // String | Bắt buộc nếu wallpaper.is_premium = true

try {
    final response = api.wallpapersIdDownloadUrlGet(id, transactionId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PublicApi->wallpapersIdDownloadUrlGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **transactionId** | **String**| Bắt buộc nếu wallpaper.is_premium = true | [optional] 

### Return type

[**DownloadUrlResponse**](DownloadUrlResponse.md)

### Authorization

[AppApiKey](../README.md#AppApiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **wallpapersIdGet**
> Wallpaper wallpapersIdGet(id)



### Example
```dart
import 'package:livecanvas_api/api.dart';
// TODO Configure API key authorization: AppApiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKeyPrefix = 'Bearer';

final api = LivecanvasApi().getPublicApi();
final int id = 56; // int | 

try {
    final response = api.wallpapersIdGet(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PublicApi->wallpapersIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Wallpaper**](Wallpaper.md)

### Authorization

[AppApiKey](../README.md#AppApiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

