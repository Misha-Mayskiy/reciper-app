// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileRepositoryHash() => r'8bdd5e70a177cec535697479ff256bb3482c3bb1';

/// See also [profileRepository].
@ProviderFor(profileRepository)
final profileRepositoryProvider =
    AutoDisposeProvider<ProfileRepository>.internal(
  profileRepository,
  name: r'profileRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileRepositoryRef = AutoDisposeProviderRef<ProfileRepository>;
String _$profileStatsHash() => r'20fc6b1eeba3389ed3517590723f120f09476439';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [profileStats].
@ProviderFor(profileStats)
const profileStatsProvider = ProfileStatsFamily();

/// See also [profileStats].
class ProfileStatsFamily extends Family<AsyncValue<List<DailyStat>>> {
  /// See also [profileStats].
  const ProfileStatsFamily();

  /// See also [profileStats].
  ProfileStatsProvider call(
    String userId,
  ) {
    return ProfileStatsProvider(
      userId,
    );
  }

  @override
  ProfileStatsProvider getProviderOverride(
    covariant ProfileStatsProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'profileStatsProvider';
}

/// See also [profileStats].
class ProfileStatsProvider extends AutoDisposeFutureProvider<List<DailyStat>> {
  /// See also [profileStats].
  ProfileStatsProvider(
    String userId,
  ) : this._internal(
          (ref) => profileStats(
            ref as ProfileStatsRef,
            userId,
          ),
          from: profileStatsProvider,
          name: r'profileStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$profileStatsHash,
          dependencies: ProfileStatsFamily._dependencies,
          allTransitiveDependencies:
              ProfileStatsFamily._allTransitiveDependencies,
          userId: userId,
        );

  ProfileStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<List<DailyStat>> Function(ProfileStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProfileStatsProvider._internal(
        (ref) => create(ref as ProfileStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<DailyStat>> createElement() {
    return _ProfileStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileStatsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProfileStatsRef on AutoDisposeFutureProviderRef<List<DailyStat>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _ProfileStatsProviderElement
    extends AutoDisposeFutureProviderElement<List<DailyStat>>
    with ProfileStatsRef {
  _ProfileStatsProviderElement(super.provider);

  @override
  String get userId => (origin as ProfileStatsProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
