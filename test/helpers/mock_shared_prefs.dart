import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Installs an in-memory `SharedPreferencesAsync` backend so tests that build
/// the real DI graph (which registers the local-data store) don't hit the
/// "platform instance must be set" error. Call in `setUp` before
/// `configureDependencies`.
void useInMemorySharedPreferences() {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
}
