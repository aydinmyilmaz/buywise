import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../../config/app_config.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _loading = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _loading;
  bool get isOnboarded => _profile != null;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    final data = await StorageService.readMap(AppConfig.storageUserKey);
    if (data != null) {
      _profile = UserProfile.fromMap(data);
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> save(UserProfile profile) async {
    _profile = profile;
    await StorageService.saveMap(AppConfig.storageUserKey, profile.toMap());
    notifyListeners();
  }

  Future<void> clear() async {
    _profile = null;
    await StorageService.delete(AppConfig.storageUserKey);
    notifyListeners();
  }

  Map<String, dynamic> get profileMap => _profile?.toMap() ?? {};
}
