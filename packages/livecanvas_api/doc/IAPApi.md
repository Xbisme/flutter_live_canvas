# livecanvas_api.api.IAPApi

## Load the API package
```dart
import 'package:livecanvas_api/api.dart';
```

All URIs are relative to *https://api.example.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**iapSubscriptionStatusGet**](IAPApi.md#iapsubscriptionstatusget) | **GET** /iap/subscription-status | 
[**iapVerifyReceiptPost**](IAPApi.md#iapverifyreceiptpost) | **POST** /iap/verify-receipt | 
[**iapWebhookApplePost**](IAPApi.md#iapwebhookapplepost) | **POST** /iap/webhook/apple | 
[**iapWebhookGooglePost**](IAPApi.md#iapwebhookgooglepost) | **POST** /iap/webhook/google | 


# **iapSubscriptionStatusGet**
> SubscriptionStatus iapSubscriptionStatusGet(transactionId)



### Example
```dart
import 'package:livecanvas_api/api.dart';
// TODO Configure API key authorization: AppApiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKeyPrefix = 'Bearer';

final api = LivecanvasApi().getIAPApi();
final String transactionId = transactionId_example; // String | 

try {
    final response = api.iapSubscriptionStatusGet(transactionId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling IAPApi->iapSubscriptionStatusGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **transactionId** | **String**|  | 

### Return type

[**SubscriptionStatus**](SubscriptionStatus.md)

### Authorization

[AppApiKey](../README.md#AppApiKey)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **iapVerifyReceiptPost**
> SubscriptionStatus iapVerifyReceiptPost(verifyReceiptRequest)



### Example
```dart
import 'package:livecanvas_api/api.dart';
// TODO Configure API key authorization: AppApiKey
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AppApiKey').apiKeyPrefix = 'Bearer';

final api = LivecanvasApi().getIAPApi();
final VerifyReceiptRequest verifyReceiptRequest = ; // VerifyReceiptRequest | 

try {
    final response = api.iapVerifyReceiptPost(verifyReceiptRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling IAPApi->iapVerifyReceiptPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **verifyReceiptRequest** | [**VerifyReceiptRequest**](VerifyReceiptRequest.md)|  | 

### Return type

[**SubscriptionStatus**](SubscriptionStatus.md)

### Authorization

[AppApiKey](../README.md#AppApiKey)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **iapWebhookApplePost**
> iapWebhookApplePost(appleServerNotification)



### Example
```dart
import 'package:livecanvas_api/api.dart';

final api = LivecanvasApi().getIAPApi();
final AppleServerNotification appleServerNotification = ; // AppleServerNotification | 

try {
    api.iapWebhookApplePost(appleServerNotification);
} catch on DioException (e) {
    print('Exception when calling IAPApi->iapWebhookApplePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **appleServerNotification** | [**AppleServerNotification**](AppleServerNotification.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **iapWebhookGooglePost**
> iapWebhookGooglePost(googleRtdnNotification)



### Example
```dart
import 'package:livecanvas_api/api.dart';

final api = LivecanvasApi().getIAPApi();
final GoogleRtdnNotification googleRtdnNotification = ; // GoogleRtdnNotification | 

try {
    api.iapWebhookGooglePost(googleRtdnNotification);
} catch on DioException (e) {
    print('Exception when calling IAPApi->iapWebhookGooglePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **googleRtdnNotification** | [**GoogleRtdnNotification**](GoogleRtdnNotification.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

