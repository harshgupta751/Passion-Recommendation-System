import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';

// ─── Domain entity ───────────────────────────────────────────────────────────

class AuthUser {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? stylePersona;
  final bool isAuthenticated;
  final bool hasCompletedQuiz;

  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.stylePersona,
    this.isAuthenticated = true,
    this.hasCompletedQuiz = false,
  });

  static const unauthenticated = AuthUser(
    id: '',
    email: '',
    isAuthenticated: false,
  );

  AuthUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? stylePersona,
    bool? isAuthenticated,
    bool? hasCompletedQuiz,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      stylePersona: stylePersona ?? this.stylePersona,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasCompletedQuiz: hasCompletedQuiz ?? this.hasCompletedQuiz,
    );
  }
}

// ─── Auth State ───────────────────────────────────────────────────────────────

class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user?.isAuthenticated ?? false;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─── Secure Storage ───────────────────────────────────────────────────────────

const _secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

// ─── Provider ─────────────────────────────────────────────────────────────────

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    return _checkStoredSession();
  }

  Future<AuthState> _checkStoredSession() async {
    final token =
        await _secureStorage.read(key: AppConstants.accessTokenKey);
    final userId =
        await _secureStorage.read(key: AppConstants.userIdKey);

    if (token != null && userId != null) {
      try {
        final dio = ref.read(dioProvider);
        final response = await dio.get('/auth/me');
        final userData =
            response.data['data'] as Map<String, dynamic>;
        return AuthState(
          user: AuthUser(
            id: userData['id'] as String,
            email: userData['email'] as String,
            displayName: userData['display_name'] as String?,
            avatarUrl: userData['avatar_url'] as String?,
            stylePersona: userData['style_persona'] as String?,
            hasCompletedQuiz:
                userData['has_completed_quiz'] as bool? ?? false,
          ),
        );
      } catch (_) {
        await _clearTokens();
        return const AuthState();
      }
    }
    return const AuthState();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      await _saveTokens(response.data as Map<String, dynamic>);
      final authState =
          _buildAuthState(response.data as Map<String, dynamic>);
      state = AsyncValue.data(authState);
    } catch (e, st) {
      state = AsyncValue.error(_extractError(e), st);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
      });
      await _saveTokens(response.data as Map<String, dynamic>);
      final authState =
          _buildAuthState(response.data as Map<String, dynamic>);
      state = AsyncValue.data(authState);
    } catch (e, st) {
      state = AsyncValue.error(_extractError(e), st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      // TODO: integrate google_sign_in package to get idToken
      // final googleUser = await GoogleSignIn().signIn();
      // final auth = await googleUser!.authentication;
      // final idToken = auth.idToken;
      const idToken = 'GOOGLE_ID_TOKEN_HERE';

      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/google', data: {
        'id_token': idToken,
      });
      await _saveTokens(response.data as Map<String, dynamic>);
      final authState =
          _buildAuthState(response.data as Map<String, dynamic>);
      state = AsyncValue.data(authState);
    } catch (e, st) {
      state = AsyncValue.error(_extractError(e), st);
    }
  }

  Future<void> signOut() async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/auth/logout');
    } catch (_) {}
    await _clearTokens();
    state = const AsyncValue.data(AuthState());
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;
    final userData = data['data'] as Map<String, dynamic>?;
    final userId = userData?['id'] as String?;

    if (accessToken != null) {
      await _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: accessToken,
      );
    }
    if (refreshToken != null) {
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: refreshToken,
      );
    }
    if (userId != null) {
      await _secureStorage.write(
        key: AppConstants.userIdKey,
        value: userId,
      );
    }
  }

  Future<void> _clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: AppConstants.accessTokenKey),
      _secureStorage.delete(key: AppConstants.refreshTokenKey),
      _secureStorage.delete(key: AppConstants.userIdKey),
    ]);
  }

  AuthState _buildAuthState(Map<String, dynamic> data) {
    final userData = data['data'] as Map<String, dynamic>;
    return AuthState(
      user: AuthUser(
        id: userData['id'] as String,
        email: userData['email'] as String,
        displayName: userData['name'] as String?,
        avatarUrl: userData['avatar_url'] as String?,
        stylePersona: userData['style_persona'] as String?,
        hasCompletedQuiz:
            userData['has_completed_quiz'] as bool? ?? false,
      ),
    );
  }

  String _extractError(dynamic e) {
    if (e is Failure) return e.message;
    return e.toString();
  }
}