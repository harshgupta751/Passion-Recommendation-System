import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/dio_client.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../domain/entities/clothing_item.dart';

// ─── Repository ─────────────────────────────────────────────────────────────

abstract class ClosetRepository {
  Future<PaginatedCloset> getItems({
    int page = 1,
    String? category,
    String? status,
    String? season,
    String? search,
  });
  Future<ClothingItem> getItem(String id);
  Future<ClothingItem> addItem(Map<String, dynamic> data, String imagePath);
  Future<ClothingItem> updateItem(String id, Map<String, dynamic> data);
  Future<void> deleteItem(String id);
  Future<ClothingItem> updateStatus(String id, String status);
  Future<ClothingItem> logWear(String id);
}

class ClosetRepositoryImpl implements ClosetRepository {
  final Dio _dio;
  ClosetRepositoryImpl(this._dio);

  @override
  Future<PaginatedCloset> getItems({
    int page = 1,
    String? category,
    String? status,
    String? season,
    String? search,
  }) async {
    final response = await _dio.get(
      '/closet/items',
      queryParameters: {
        'page': page,
        'page_size': AppConstants.pageSize,
        if (category != null && category != 'All') 'category': category,
        if (status != null) 'status': status,
        if (season != null) 'season': season,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return PaginatedCloset.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ClothingItem> getItem(String id) async {
    final response = await _dio.get('/closet/items/$id');
    return ClothingItem.fromJson(
        (response.data as Map<String, dynamic>)['data']
            as Map<String, dynamic>);
  }

  @override
  Future<ClothingItem> addItem(
      Map<String, dynamic> data, String imagePath) async {
    final formData = FormData.fromMap({
      ...data,
      'image': await MultipartFile.fromFile(imagePath),
    });
    final response = await _dio.post('/closet/items', data: formData);
    return ClothingItem.fromJson(
        (response.data as Map<String, dynamic>)['data']
            as Map<String, dynamic>);
  }

  @override
  Future<ClothingItem> updateItem(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/closet/items/$id', data: data);
    return ClothingItem.fromJson(
        (response.data as Map<String, dynamic>)['data']
            as Map<String, dynamic>);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _dio.delete('/closet/items/$id');
  }

  @override
  Future<ClothingItem> updateStatus(String id, String status) async {
    final response = await _dio.patch(
      '/closet/items/$id/status',
      data: {'status': status},
    );
    return ClothingItem.fromJson(
        (response.data as Map<String, dynamic>)['data']
            as Map<String, dynamic>);
  }

  @override
  Future<ClothingItem> logWear(String id) async {
    final response = await _dio.post('/closet/items/$id/wear');
    return ClothingItem.fromJson(
        (response.data as Map<String, dynamic>)['data']
            as Map<String, dynamic>);
  }
}

final closetRepositoryProvider = Provider<ClosetRepository>((ref) {
  return ClosetRepositoryImpl(ref.read(dioProvider));
});

// ─── Filter State ────────────────────────────────────────────────────────────

class ClosetFilter {
  final String category;
  final String? status;
  final String? season;
  final String searchQuery;

  const ClosetFilter({
    this.category = 'All',
    this.status,
    this.season,
    this.searchQuery = '',
  });

  ClosetFilter copyWith({
    String? category,
    String? status,
    String? season,
    String? searchQuery,
  }) =>
      ClosetFilter(
        category: category ?? this.category,
        status: status ?? this.status,
        season: season ?? this.season,
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

final closetFilterProvider =
    StateProvider<ClosetFilter>((ref) => const ClosetFilter());

// ─── Closet State ─────────────────────────────────────────────────────────────

class ClosetState {
  final List<ClothingItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final int totalCount;

  const ClosetState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
    this.totalCount = 0,
  });

  ClosetState copyWith({
    List<ClothingItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? error,
    int? totalCount,
  }) =>
      ClosetState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        error: error,
        totalCount: totalCount ?? this.totalCount,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

final closetProvider =
    StateNotifierProvider<ClosetNotifier, ClosetState>((ref) {
  return ClosetNotifier(ref);
});

class ClosetNotifier extends StateNotifier<ClosetState> {
  final Ref _ref;
  Timer? _debounce;

  ClosetNotifier(this._ref) : super(const ClosetState()) {
    _init();
  }

  void _init() {
    _ref.listen(closetFilterProvider, (prev, next) {
      if (prev?.category != next.category ||
          prev?.status != next.status ||
          prev?.season != next.season ||
          prev?.searchQuery != next.searchQuery) {
        _debounce?.cancel();
        _debounce =
            Timer(const Duration(milliseconds: 300), () => refresh());
      }
    });
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, currentPage: 0, items: []);
    final filter = _ref.read(closetFilterProvider);
    try {
      final repo = _ref.read(closetRepositoryProvider);
      final result = await repo.getItems(
        page: 1,
        category: filter.category,
        status: filter.status,
        season: filter.season,
        search: filter.searchQuery,
      );
      state = state.copyWith(
        items: result.items,
        isLoading: false,
        hasMore: result.hasMore,
        currentPage: 1,
        totalCount: result.total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    final filter = _ref.read(closetFilterProvider);
    try {
      final repo = _ref.read(closetRepositoryProvider);
      final result = await repo.getItems(
        page: state.currentPage + 1,
        category: filter.category,
        status: filter.status,
        season: filter.season,
        search: filter.searchQuery,
      );
      state = state.copyWith(
        items: [...state.items, ...result.items],
        isLoadingMore: false,
        hasMore: result.hasMore,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> updateItemStatus(String id, String status) async {
    try {
      final repo = _ref.read(closetRepositoryProvider);
      final updated = await repo.updateStatus(id, status);
      state = state.copyWith(
        items: state.items.map((i) => i.id == id ? updated : i).toList(),
      );
    } catch (_) {}
  }

  Future<void> deleteItem(String id) async {
    try {
      final repo = _ref.read(closetRepositoryProvider);
      await repo.deleteItem(id);
      state = state.copyWith(
        items: state.items.where((i) => i.id != id).toList(),
        totalCount: state.totalCount - 1,
      );
    } catch (_) {}
  }

  void addItemLocally(ClothingItem item) {
    state = state.copyWith(
      items: [item, ...state.items],
      totalCount: state.totalCount + 1,
    );
  }
}