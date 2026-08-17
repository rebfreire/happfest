import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/network/api_exception.dart';
import 'package:happfest/design_system/feedback/app_empty_state.dart';
import 'package:happfest/design_system/feedback/app_error_state.dart';
import 'package:happfest/design_system/feedback/app_loading.dart';

/// Trata os 4 estados de tela (loading/vazio/erro/conteúdo) a partir de um
/// `AsyncValue<T>` do Riverpod — nenhuma tela decide isso na mão (ver
/// AGENTS.md seção 3.4).
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    required this.value,
    required this.data,
    super.key,
    this.loading,
    this.error,
    this.empty,
    this.isEmpty,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Failure failure, VoidCallback? retry)? error;
  final Widget Function()? empty;
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading?.call() ?? const AppLoading.skeleton(),
      error: (err, stackTrace) {
        final failure = err is ApiException
            ? err.failure
            : const UnknownFailure();
        if (error != null) return error!(failure, null);
        return AppErrorState(failure: failure);
      },
      data: (result) {
        if (isEmpty?.call(result) ?? false) {
          return empty?.call() ??
              const AppEmptyState(message: 'Nada por aqui.');
        }
        return data(result);
      },
    );
  }
}
