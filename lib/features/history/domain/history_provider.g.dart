// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$historyHash() => r'5966d14f605ac71758c6cef2649246fa22ae8e68';

/// See also [History].
@ProviderFor(History)
final historyProvider =
    AutoDisposeAsyncNotifierProvider<History, List<HistoryItem>>.internal(
      History.new,
      name: r'historyProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historyHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$History = AutoDisposeAsyncNotifier<List<HistoryItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
