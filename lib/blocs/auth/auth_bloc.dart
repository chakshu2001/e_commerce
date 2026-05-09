import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/api_client.dart';
import '../../utils/cache_manager.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final token = await cacheManager.getToken();
    if (token != null) {
      emit(Authenticated(token));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await apiClient.post('/auth/login', {
        'username': event.username,
        'password': event.password,
      });
      final data = jsonDecode(response.body);
      final token = data['token'];
      await cacheManager.saveToken(token);
      Fluttertoast.showToast(msg: "Login Successful");
      emit(Authenticated(token));
    } catch (e) {
      Fluttertoast.showToast(msg: "Login Failed: $e");
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await cacheManager.removeToken();
    Fluttertoast.showToast(msg: "Logged Out");
    emit(Unauthenticated());
  }
}
