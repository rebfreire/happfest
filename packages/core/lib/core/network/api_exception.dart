import 'package:happfest_core/core/error/failure.dart';

/// Wraps a typed [Failure] so repositories can catch a single exception
/// type instead of inspecting raw Dio exceptions.
class ApiException implements Exception {
  const ApiException(this.failure);

  final Failure failure;

  @override
  String toString() {
    return 'ApiException(${failure.runtimeType}: ${failure.message})';
  }
}
