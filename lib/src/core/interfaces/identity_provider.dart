/// Abstract interface for user identity providers.
/// Allows the package to be auth-agnostic (Firebase Auth, Supabase Auth, custom auth, etc.)
abstract class IdentityProvider {
  /// Gets the current authenticated user's ID.
  ///
  /// Returns null if no user is authenticated.
  String? getCurrentUserId();

  /// A stream that emits the current user's ID whenever it changes.
  ///
  /// Emits null when the user logs out.
  /// This is used to automatically update the avatar when the user changes.
  Stream<String?> get userIdStream;
}
