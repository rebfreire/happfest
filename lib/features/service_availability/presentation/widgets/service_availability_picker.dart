import 'package:flutter/material.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/service_availability/domain/entities/service_availability.dart';
import 'package:table_calendar/table_calendar.dart';

/// Calendário + seletor de horário para produtos `SERVICE`. Só habilita as
/// datas presentes em `availability.availableDates` — o resto fica
/// desabilitado, seguindo a disponibilidade real calculada pela API para a
/// quantidade/duração selecionadas.
class ServiceAvailabilityPicker extends StatelessWidget {
  const ServiceAvailabilityPicker({
    required this.availability,
    required this.selectedDate,
    required this.onDateSelected,
    required this.selectedTime,
    required this.onTimeSelected,
    super.key,
  });

  final ServiceAvailability availability;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? selectedTime;
  final ValueChanged<String> onTimeSelected;

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    if (!availability.hasAvailability) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Não há datas disponíveis para esse serviço no momento.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      );
    }

    final dates = availability.availableDates.map((e) => e.date).toList()
      ..sort();
    final firstDay = dates.first;
    final lastDay = dates.last;
    final focusedDay = selectedDate ?? firstDay;
    final times = selectedDate != null
        ? availability.timesFor(selectedDate!)
        : const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escolha uma data',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        TableCalendar<void>(
          firstDay: firstDay,
          lastDay: lastDay,
          focusedDay: focusedDay,
          locale: 'pt_BR',
          availableGestures: AvailableGestures.horizontalSwipe,
          selectedDayPredicate: (day) =>
              selectedDate != null && _isSameDate(day, selectedDate!),
          enabledDayPredicate: availability.isDateAvailable,
          onDaySelected: (day, focused) => onDateSelected(day),
          calendarStyle: const CalendarStyle(
            disabledTextStyle: TextStyle(color: Colors.black26),
            outsideDaysVisible: false,
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        if (selectedDate != null && availability.timeSelectionRequired) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Escolha um horário',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (times.isEmpty)
            const Text('Nenhum horário disponível para essa data.')
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final time in times)
                  ChoiceChip(
                    label: Text(time.substring(0, 5)),
                    selected: selectedTime == time,
                    onSelected: (_) => onTimeSelected(time),
                  ),
              ],
            ),
        ],
      ],
    );
  }
}
