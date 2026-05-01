import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  static final Map<String, String> _memory = {};

  static bool _didProbe = false;
  static bool _useMemory = false;

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> _probe() async {
    if (_didProbe) return;
    _didProbe = true;
    try {
      await _storage.read(key: '__secure_storage_probe__');
    } on MissingPluginException {
      _useMemory = true;
      _memory.clear();
    }
  }

  static Future<void> init() async {
    await _probe();
    if (_useMemory) return;
    await _storage.containsKey(key: '__init__');
  }

  static Future<void> saveAuthToken(String token) async {
    await _write('auth_token', token);
  }

  static Future<String?> getAuthToken() async {
    return _read('auth_token');
  }

  static Future<void> deleteAuthToken() async {
    await _delete('auth_token');
  }

  static Future<void> saveUserCredentials(
      String username, String password) async {
    await Future.wait([
      _write('username', username),
      _write('password', password),
    ]);
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    final credentials = await Future.wait([
      _read('username'),
      _read('password'),
    ]);
    return {
      'username': credentials[0],
      'password': credentials[1],
    };
  }

  static Future<void> deleteUserCredentials() async {
    await Future.wait([
      _delete('username'),
      _delete('password'),
    ]);
  }

  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _write('biometric_enabled', enabled.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _read('biometric_enabled');
    return value?.toLowerCase() == 'true';
  }

  static Future<void> saveSecureData(String key, String value) async {
    await _write(key, value);
  }

  static Future<String?> getSecureData(String key) async {
    return _read(key);
  }

  static Future<void> deleteSecureData(String key) async {
    await _delete(key);
  }

  static Future<void> saveObject(
      String key, Map<String, dynamic> object) async {
    final jsonString = jsonEncode(object);
    await _write(key, jsonString);
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _read(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  static Future<bool> containsKey(String key) async {
    await _probe();
    if (_useMemory) {
      return _memory.containsKey(key);
    }
    return _storage.containsKey(key: key);
  }

  static Future<List<String>> getAllKeys() async {
    final allData = await _readAll();
    return allData.keys.toList();
  }

  static Future<void> clearAll() async {
    await _probe();
    if (_useMemory) {
      _memory.clear();
      return;
    }
    await _storage.deleteAll();
  }

  static Future<Map<String, String>> exportData() async {
    return _readAll();
  }

  static Future<void> _write(String key, String value) async {
    await _probe();
    if (_useMemory) {
      _memory[key] = value;
      return;
    }
    await _storage.write(key: key, value: value);
  }

  static Future<String?> _read(String key) async {
    await _probe();
    if (_useMemory) {
      return _memory[key];
    }
    return _storage.read(key: key);
  }

  static Future<void> _delete(String key) async {
    await _probe();
    if (_useMemory) {
      _memory.remove(key);
      return;
    }
    await _storage.delete(key: key);
  }

  static Future<Map<String, String>> _readAll() async {
    await _probe();
    if (_useMemory) {
      return Map<String, String>.from(_memory);
    }
    return _storage.readAll();
  }
}
