import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/auth_api.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:appwrite/models.dart' as model;
import 'package:twitter_clone/models/user_model.dart';

import '../../home/view/home_view.dart';
import '../view/login_view.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  final authApiProvider = ref.watch(authAPIProvider);
  final userApiProvider = ref.watch(userAPIprovider);
  return AuthController(
    authAPI: authApiProvider,
    userAPI: userApiProvider,
  );
});

final currentUserAccountProvider = FutureProvider((ref) async {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.currentUser();
});

class AuthController extends StateNotifier<bool> {
  AuthController({required AuthAPI authAPI, required UserAPI userAPI})
      : _authAPI = authAPI,
        _userAPI = userAPI,
        super(false);
  final AuthAPI _authAPI;
  final UserAPI _userAPI;

  Future<model.Account?> currentUser() => _authAPI.currentUserAccount();

  void signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.signUp(email: email, password: password);
    state = false;
    res.fold((l) {
      showSnackBar(context, l.message);
    }, (r) async {
      UserModel userModel = UserModel(
        email: email,
        name: getNameFromEmail(email),
        followers: const [],
        following: const [],
        profilePic: '',
        bannerPic: '',
        uid: '',
        bio: '',
        isTwitterBlue: false,
      );
      final res2 = await _userAPI.saveUserData(userModel);
      res2.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Account has been created! Please login');
        Navigator.push(context, LoginView.route());
      });
    });
  }

  void login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.login(email: email, password: password);
    state = false;
    res.fold((l) {
      showSnackBar(context, l.message);
    }, (r) {
      showSnackBar(context, 'Account has been created! Please login');
      Navigator.push(context, HomeView.route());
    });
  }
}
