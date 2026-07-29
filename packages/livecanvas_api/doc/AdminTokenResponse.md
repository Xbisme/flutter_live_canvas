# livecanvas_api.model.AdminTokenResponse

## Load the model package
```dart
import 'package:livecanvas_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**access** | **String** | JWT access — gắn `Authorization Bearer` cho /admin/_*, sống 30 phút | [optional] 
**refresh** | **String** | Refresh token MỚI (rotate mỗi lần dùng; bản cũ bị vô hiệu), sống 7 ngày | [optional] 
**expiresIn** | **int** | Số giây còn lại của access token | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


