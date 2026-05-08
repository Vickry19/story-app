import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';

class AuthProvider extends ChangeNotifier {
  bool isLogin = false;
  String? token;

  final api = ApiService();

  AuthProvider() {
    checkLogin();
  }

  Future<void> checkLogin() async {
    token = await Session.getToken();
    isLogin = token != null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final data = await api.login(email, password);
    if (!data['error']) {
      token = data['loginResult']['token'];
      await Session.saveToken(token!);
      isLogin = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<String> register(String name, String email, String password) async {
    final data = await api.register(name, email, password);

    if (!data['error']) {
      return "Register berhasil";
    } else {
      return data['message'];
    }
  }

  void logout() async {
    await Session.clear();
    isLogin = false;
    notifyListeners();
  }
}
