import 'package:firebase_auth/firebase_auth.dart';

import '../core/interfaces/identity_provider.dart';

/// Firebase Auth implementation of [IdentityProvider].
class FirebaseIdentityProvider implements IdentityProvider {
  final FirebaseAuth auth;

  const FirebaseIdentityProvider(this.auth);

  @override
  String? getCurrentUserId() {
    return auth.currentUser?.uid;
  }

  @override
  Stream<String?> get userIdStream {
    return auth.authStateChanges().map((user) => user?.uid);
  }
}
