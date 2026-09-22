import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoggedIn;
  final String name;
  final String email;
  final String? photoUrl;

  const AuthState({
    required this.isLoggedIn,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? name,
    String? email,
    String? photoUrl,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(const AuthState(
          isLoggedIn: true,
          name: 'Ali Valiyev',
          email: 'ali.valiyev@ihda.uz',
        ));

  void login({required String name, required String email}) {
    state = AuthState(
      isLoggedIn: true,
      name: name,
      email: email,
    );
  }

  void logout() {
    state = state.copyWith(isLoggedIn: false);
  }

  void updateProfile({required String name, required String email}) {
    state = state.copyWith(name: name, email: email);
  }

  void updatePhoto(String photoUrl) {
    state = state.copyWith(photoUrl: photoUrl);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
