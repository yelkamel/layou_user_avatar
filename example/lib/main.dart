import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:layou_user_avatar/layou_user_avatar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // Note: You need to add your own firebase_options.dart
  // Run: flutterfire configure
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase initialization failed
    // Please run: flutterfire configure
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        // Configure the avatar package
        avatarConfigProvider.overrideWithValue(
          AvatarConfig(
            storageProvider: FirebaseStorageProviderWithProgress(
              FirebaseStorage.instance,
            ),
            localCacheProvider: HiveCacheProvider(),
            identityProvider: FirebaseIdentityProvider(
              FirebaseAuth.instance,
            ),
            imageConverter: WebPImageConverter(),
            pathBuilder: (userId) => 'avatars/$userId/avatar.webp',
            cacheTtl: const Duration(hours: 24),
            webpQuality: 85,
            maxImageSize: 512,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avatar Package Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

/// Wrapper that shows login or home based on auth state
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

/// Simple login screen for demo
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Avatar Package Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _signInAnonymously(context),
              child: const Text('Sign In Anonymously'),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Note: This is a demo app. You need to configure Firebase to use it.\n\n'
                'Run: flutterfire configure',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e')),
        );
      }
    }
  }
}

/// Home screen demonstrating all avatar features
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Avatar Editor (Vertical Layout)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: AvatarEditor(
                size: 120,
                layout: AvatarEditorLayout.vertical,
                onUploadSuccess: (url) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Avatar uploaded!')),
                  );
                },
                onUploadError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Upload failed: $error')),
                  );
                },
                onDeleteSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Avatar deleted!')),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            const Text(
              'Avatar Editor (Horizontal Layout)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: AvatarEditor(
                size: 100,
                layout: AvatarEditorLayout.horizontal,
                onUploadSuccess: (url) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Avatar uploaded!')),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            const Text(
              'Avatar Editor (Overlay Layout)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: AvatarEditor(
                size: 120,
                layout: AvatarEditorLayout.overlay,
                onUploadSuccess: (url) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Avatar uploaded!')),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            const Text(
              'Read-Only Avatar Display',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const CurrentUserAvatarDisplay(),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            const Text(
              'Avatar Sizes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const AvatarSizesDemo(),
          ],
        ),
      ),
    );
  }
}

/// Demo showing read-only avatar display
class CurrentUserAvatarDisplay extends ConsumerWidget {
  const CurrentUserAvatarDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(currentUserAvatarProvider);

    return avatarState.when(
      data: (state) {
        if (state is AvatarData) {
          return Center(
            child: AvatarDisplay(
              avatarUrl: state.url,
              userId: FirebaseAuth.instance.currentUser?.uid,
              size: 80,
            ),
          );
        }
        return const Center(child: Text('Loading...'));
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

/// Demo showing different avatar sizes
class AvatarSizesDemo extends ConsumerWidget {
  const AvatarSizesDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(currentUserAvatarProvider);

    return avatarState.when(
      data: (state) {
        final url = state is AvatarData ? state.url : null;
        final userId = FirebaseAuth.instance.currentUser?.uid;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                AvatarDisplay(
                  avatarUrl: url,
                  userId: userId,
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text('32px'),
              ],
            ),
            Column(
              children: [
                AvatarDisplay(
                  avatarUrl: url,
                  userId: userId,
                  size: 48,
                ),
                const SizedBox(height: 8),
                const Text('48px'),
              ],
            ),
            Column(
              children: [
                AvatarDisplay(
                  avatarUrl: url,
                  userId: userId,
                  size: 64,
                ),
                const SizedBox(height: 8),
                const Text('64px'),
              ],
            ),
            Column(
              children: [
                AvatarDisplay(
                  avatarUrl: url,
                  userId: userId,
                  size: 96,
                ),
                const SizedBox(height: 8),
                const Text('96px'),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
