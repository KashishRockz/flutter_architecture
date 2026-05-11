// lib/core/auth_event.dart
import 'dart:async';

enum AuthEvent { sessionExpired }

class AuthEventBus {
  AuthEventBus._();
  static final _controller = StreamController<AuthEvent>.broadcast();
  static Stream<AuthEvent> get stream => _controller.stream;
  static void emit(AuthEvent event)   => _controller.add(event);
}