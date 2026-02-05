# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.3] - 2026-02-05

### Changed
- Updated dependency constraints to support Riverpod 3.x and 4.x:
  - `flutter_riverpod: '>=2.5.0 <5.0.0'` (supports v2.x, v3.x, and v4.x)
  - `riverpod_annotation: '>=2.3.0 <5.0.0'`
  - `riverpod_generator: '>=2.3.0 <5.0.0'`
  - `flutter_lints: ^4.0.0`
- Verified compatibility with Riverpod 3.x API (no deprecation warnings)
- Package uses manual provider syntax which is compatible across all Riverpod versions

### Notes
- This package does not use Riverpod code generation (`@riverpod` annotations)
- All providers use the manual syntax: `Provider<T>((ref) {})` which is fully compatible with Riverpod 2.x, 3.x, and 4.x
- No breaking changes in this release

## [0.1.2] - 2026-02-03

### Fixed
- Fixed "Error loading avatar" crash for new users without avatar - now shows placeholder gracefully
- AvatarEditor now treats missing avatar errors as empty state instead of error state

### Added
- Added EXAMPLES.md with clear, working code examples
- Better error handling for edge cases

## [0.1.1] - 2026-02-03

### Changed
- Updated dependency constraints to support wider version ranges:
  - `firebase_storage: '>=11.6.0 <14.0.0'` (supports v12.x and v13.x)
  - `firebase_auth: '>=4.15.0 <7.0.0'`
  - `flutter_riverpod: '>=2.5.0 <4.0.0'`
  - Other dependencies updated to flexible version ranges
- Improved compatibility with existing Flutter projects using newer Firebase versions

## [0.1.0] - 2026-02-03

### Added
- Initial release
- Avatar upload with automatic WebP conversion using `flutter_image_compress`
  - Native WebP support on Android and iOS
  - 25-35% better compression than PNG/JPEG
  - Automatic image resizing with aspect ratio preservation
- Avatar deletion functionality
- Local and memory caching with TTL support
- Firebase Storage provider implementation with progress tracking
- Hive cache provider implementation
- Riverpod state management integration
- Customizable widgets: AvatarEditor, AvatarDisplay, AvatarUploadButton, AvatarDeleteButton
- Progress callbacks for upload operations
- Configurable storage paths
- Cache busting support
- Extensible provider interfaces for storage, cache, identity, and image conversion
- Alternative WebPImageConverterFromBytes for in-memory processing
