/// A customizable Flutter package for user avatar management.
///
/// This package provides a complete solution for handling user avatars with:
/// - Upload and delete functionality
/// - Automatic WebP conversion
/// - Local and memory caching
/// - Customizable widgets
/// - Riverpod integration
/// - Firebase Storage support (extensible to other providers)
library layou_user_avatar;

// Core interfaces
export 'src/core/interfaces/storage_provider.dart';
export 'src/core/interfaces/local_cache_provider.dart';
export 'src/core/interfaces/identity_provider.dart';
export 'src/core/interfaces/image_converter.dart';

// Models
export 'src/core/models/avatar_config.dart';
export 'src/core/models/avatar_state.dart';
export 'src/core/models/upload_state.dart';

// Services
export 'src/services/avatar_service.dart';
export 'src/services/avatar_cache_manager.dart';

// Providers
export 'src/providers/avatar_providers.dart';

// Widgets
export 'src/widgets/avatar_display.dart';
export 'src/widgets/avatar_upload_button.dart';
export 'src/widgets/avatar_delete_button.dart';
export 'src/widgets/avatar_editor.dart';

// Default implementations
export 'src/implementations/firebase_storage_provider.dart';
export 'src/implementations/firebase_identity_provider.dart';
export 'src/implementations/hive_cache_provider.dart';
export 'src/implementations/webp_image_converter.dart';

// Utilities
export 'src/core/utils/cache_busting.dart';
export 'src/core/utils/path_builder.dart';
