import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides the shared [SharedPreferencesAsync] handle for the local-data layer
/// (favorite IDs + download history — Principle IX). The modern async API needs
/// no `getInstance()` await, so a plain instance is enough.
///
/// Only non-sensitive references (IDs, timestamps) live here; `transaction_id`
/// uses secure storage instead (MO-006).
@module
abstract class LocalDataModule {
  @lazySingleton
  SharedPreferencesAsync sharedPreferences() => SharedPreferencesAsync();
}
