// lib/core/api_state.dart
enum ApiStatus { initial, loading, success, error }

class ApiState {
  final ApiStatus status;
  final String? error;

  const ApiState._({required this.status, this.error});

  const ApiState.initial() : this._(status: ApiStatus.initial);
  const ApiState.loading() : this._(status: ApiStatus.loading);
  const ApiState.success() : this._(status: ApiStatus.success);
  const ApiState.error(String message)
      : this._(status: ApiStatus.error, error: message);

  bool get isLoading => status == ApiStatus.loading;
  bool get isSuccess => status == ApiStatus.success;
  bool get isError   => status == ApiStatus.error;
  bool get isInitial => status == ApiStatus.initial;
}