import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/api_response_model.dart';

class StorageService {
  static StorageService? _instance;
  late final FlutterSecureStorage _secureStorage;
  SharedPreferences? _prefs;

  factory StorageService() {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  StorageService._internal() {
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Secure Storage - Access Token
  Future<void> setAccessToken(String token) async {
    await _secureStorage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.accessTokenKey);
  }

  Future<void> deleteAccessToken() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
  }

  // Secure Storage - Refresh Token
  Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  // Secure Storage - User Data
  Future<void> setUserData(UserData user) async {
    await _secureStorage.write(
      key: AppConstants.userDataKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<UserData?> getUserData() async {
    final data = await _secureStorage.read(key: AppConstants.userDataKey);
    if (data == null) return null;
    return UserData.fromJson(jsonDecode(data));
  }

  Future<void> deleteUserData() async {
    await _secureStorage.delete(key: AppConstants.userDataKey);
  }

  // Clear All Secure Storage
  Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
  }

  // Clear All Storage
  Future<void> clearAll() async {
    await clearSecureStorage();
    await prefs.clear();
  }

  // SharedPreferences - Theme
  Future<void> setThemeMode(String mode) async {
    await prefs.setString(AppConstants.themeKey, mode);
  }

  String getThemeMode() {
    return prefs.getString(AppConstants.themeKey) ?? 'system';
  }

  // SharedPreferences - Language
  Future<void> setLanguage(String languageCode) async {
    await prefs.setString(AppConstants.languageKey, languageCode);
  }

  String getLanguage() {
    return prefs.getString(AppConstants.languageKey) ?? 'en';
  }

  // SharedPreferences - Onboarding
  Future<void> setOnboardingComplete(bool complete) async {
    await prefs.setBool(AppConstants.onboardingKey, complete);
  }

  bool getOnboardingComplete() {
    return prefs.getBool(AppConstants.onboardingKey) ?? false;
  }

  // SharedPreferences - Application ID (for staff registration)
  Future<void> setApplicationId(int id) async {
    await prefs.setInt(AppConstants.applicationIdKey, id);
  }

  int? getApplicationId() {
    return prefs.getInt(AppConstants.applicationIdKey);
  }

  Future<void> deleteApplicationId() async {
    await prefs.remove(AppConstants.applicationIdKey);
  }

  // Generic Methods
  Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return prefs.getInt(key);
  }

  Future<void> remove(String key) async {
    await prefs.remove(key);
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}