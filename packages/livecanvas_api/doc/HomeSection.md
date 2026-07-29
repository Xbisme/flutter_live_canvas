# livecanvas_api.model.HomeSection

## Load the model package
```dart
import 'package:livecanvas_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**key** | **String** | Slug của collection. Định danh ổn định cho client (analytics/scroll-state) — đổi `title` không làm đổi `key`.  | 
**title** | **String** |  | 
**collectionId** | **int** | Target của \"Xem tất cả\" → `GET /collections/{id}` (đã có). | 
**coverUrl** | **String** |  | [optional] 
**accentColor** | **String** |  | [optional] 
**isPremium** | **bool** | CHỈ để hiển thị badge/nút \"Mở khoá\" — KHÔNG phải gate entitlement. | 
**items** | [**List&lt;Wallpaper&gt;**](Wallpaper.md) | Tối đa 10 wallpaper published theo đúng thứ tự curate (`position`). Cùng schema Wallpaper như mọi list khác — `collections` rỗng.  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


