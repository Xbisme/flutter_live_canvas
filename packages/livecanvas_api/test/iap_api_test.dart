import 'package:test/test.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// tests for IAPApi
void main() {
  final instance = LivecanvasApi().getIAPApi();

  group(IAPApi, () {
    //Future<SubscriptionStatus> iapSubscriptionStatusGet(String transactionId) async
    test('test iapSubscriptionStatusGet', () async {
      // TODO
    });

    //Future<SubscriptionStatus> iapVerifyReceiptPost(VerifyReceiptRequest verifyReceiptRequest) async
    test('test iapVerifyReceiptPost', () async {
      // TODO
    });

    //Future iapWebhookApplePost(AppleServerNotification appleServerNotification) async
    test('test iapWebhookApplePost', () async {
      // TODO
    });

    //Future iapWebhookGooglePost(GoogleRtdnNotification googleRtdnNotification) async
    test('test iapWebhookGooglePost', () async {
      // TODO
    });
  });
}
