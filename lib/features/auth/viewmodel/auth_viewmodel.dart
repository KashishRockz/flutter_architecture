// lib/features/auth/viewmodel/auth_viewmodel.dart
import 'package:flutter_not_ai/features/auth/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api_state.dart';
import '../../../../core/dio_provider.dart';
import '../../../../core/repository/app_repository.dart';
import '../enum/auth_enum.dart';

// No autoDispose — auth state lives for the entire app lifetime
final authViewModelProvider =
NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);

class AuthViewModel extends Notifier<AuthState> {

  @override
  AuthState build() {
    // Initialize all enum values with ApiState.initial
    _checkExistingSession();
    return AuthState(
      apiStates: {
        for (var e in AuthEnum.values) e: const ApiState.initial()
      },
    );
  }

  // ── Check saved token on app start ────────────────────────────────────────
  Future<void> _checkExistingSession() async {
    final hasToken = await ref.read(tokenStorageProvider).hasToken();
    if (hasToken) {
      state = state.copyWith(isAuthenticated: true);
      await getUserDetails();
    }
  }

  // ── LOGIN ──────────────────────────────────────────────────────────────────
  Future<void> login(String username, String password) async {
    _setLoading(AuthEnum.login);

    final result = await ref.read(appRepositoryProvider).login(username, password);

    result.fold(
          (error) => _setError(AuthEnum.login, error),
          (data) async {
        await ref.read(tokenStorageProvider).saveTokens(
          accessToken: data['accessToken']  as String,
          refreshToken:  data['refreshToken'] as String?,
        );
        state = state.copyWith(isAuthenticated: true);
        _setSuccess(AuthEnum.login);
        await getUserDetails();
      },
    );
  }

  // ── LOGOUT ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _setLoading(AuthEnum.logout);

    // Clear tokens first — always log out locally even if API fails
    await ref.read(tokenStorageProvider).clearTokens();

    final result = await ref.read(appRepositoryProvider).logout();

    // fold both cases to same outcome — local logout always succeeds
    result.fold(
          (_) {
        state = state.copyWith(isAuthenticated: false, user: null);
        _setSuccess(AuthEnum.logout);
      },
          (_) {
        state = state.copyWith(isAuthenticated: false, user: null);
        _setSuccess(AuthEnum.logout);
      },
    );
  }

  // ── Called from main.dart after session expired dialog ────────────────────
  Future<void> forceLogout() async {
    await ref.read(tokenStorageProvider).clearTokens();
    state = state.copyWith(isAuthenticated: false, user: null);
  }

  // ── GET USER DETAILS ───────────────────────────────────────────────────────
  Future<void> getUserDetails() async {
    _setLoading(AuthEnum.userDetails);

    final result = await ref.read(appRepositoryProvider).getUserDetails();

    result.fold(
          (error) => _setError(AuthEnum.userDetails, error),
          (user) {
        state = state.copyWith(user: user);
        _setSuccess(AuthEnum.userDetails);
      },
    );
  }

  // ── Helpers — manual version of your team's BaseViewModelMixin ─────────────
  void _setLoading(AuthEnum type) => state = state.copyWith(
      apiStates: {...state.apiStates, type: const ApiState.loading()});

  void _setSuccess(AuthEnum type) => state = state.copyWith(
      apiStates: {...state.apiStates, type: const ApiState.success()});

  void _setError(AuthEnum type, String error) => state = state.copyWith(
      apiStates: {...state.apiStates, type: ApiState.error(error)});
}