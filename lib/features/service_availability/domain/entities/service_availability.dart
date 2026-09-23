import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_availability.freezed.dart';

@freezed
abstract class ServiceAvailabilityDate with _$ServiceAvailabilityDate {
  const factory ServiceAvailabilityDate({
    required DateTime date,
    @Default([]) List<String> availableTimes,
  }) = _ServiceAvailabilityDate;
}

@freezed
abstract class ServiceAvailability with _$ServiceAvailability {
  const factory ServiceAvailability({
    @Default(false) bool timeSelectionRequired,
    @Default([]) List<ServiceAvailabilityDate> availableDates,
  }) = _ServiceAvailability;

  const ServiceAvailability._();

  bool get hasAvailability => availableDates.isNotEmpty;

  List<String> timesFor(DateTime date) {
    for (final entry in availableDates) {
      if (_isSameDate(entry.date, date)) return entry.availableTimes;
    }
    return const [];
  }

  bool isDateAvailable(DateTime date) {
    return availableDates.any((entry) => _isSameDate(entry.date, date));
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
