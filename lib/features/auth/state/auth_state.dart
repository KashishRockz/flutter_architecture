// lib/features/auth/state/auth_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/api_state.dart';
import '../enum/auth_enum.dart';
import '../model/user_model.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    required Map<AuthEnum, ApiState> apiStates,
    @Default(null) UserModel? user,
    @Default(false) bool isAuthenticated,
  }) = _AuthState;

  bool isApiLoaclearding(AuthEnum type)   => apiStates[type]?.isLoading ?? false;
  bool isApiSuccess(AuthEnum type)   => apiStates[type]?.isSuccess ?? false;
  bool isApiError(AuthEnum type)     => apiStates[type]?.isError   ?? false;
  String? getApiError(AuthEnum type) => apiStates[type]?.error;
}