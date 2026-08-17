import 'package:flutter/material.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/design_system/feedback/app_empty_state.dart';
import 'package:happfest/design_system/feedback/app_error_state.dart';

/// Lista com paginação infinita + loading/erro/vazio já tratados — dispara
/// [onLoadMore] quando o scroll chega perto do fim.
class AppPagedListView<T> extends StatefulWidget {
  const AppPagedListView({
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    super.key,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.loadMoreFailure,
    this.emptyMessage = 'Nada por aqui.',
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;
  final Failure? loadMoreFailure;
  final String emptyMessage;

  @override
  State<AppPagedListView<T>> createState() => _AppPagedListViewState<T>();
}

class _AppPagedListViewState<T> extends State<AppPagedListView<T>> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore) return;
    final threshold = _controller.position.maxScrollExtent - 200;
    if (_controller.position.pixels >= threshold) {
      widget.onLoadMore();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoadingMore) {
      return AppEmptyState(message: widget.emptyMessage);
    }

    return ListView.builder(
      controller: _controller,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          if (widget.loadMoreFailure != null) {
            return AppErrorState(
              failure: widget.loadMoreFailure!,
              onRetry: widget.onLoadMore,
            );
          }
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.itemBuilder(context, widget.items[index]);
      },
    );
  }
}
