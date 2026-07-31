import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/models/user_model.dart';

/// Caches the authenticated user's profile locally. Needed because
/// reqres.in's `/api/login` and `/api/register` only return a token —
/// no user object — so the richer profile (name, phone, KTP) collected
/// on our forms has nowhere to live except on-device.
class UserCacheStorage {
  static const _userKey = 'auth_cached_user';

  final FlutterSecureStorage _storage;

  const UserCacheStorage(this._storage);

  Future<void> save(UserModel user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<UserModel?> read() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clear() async {
    await _storage.delete(key: _userKey);
  }
}

final userCacheStorageProvider = Provider<UserCacheStorage>((ref) {
  return const UserCacheStorage(FlutterSecureStorage());
});
