import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/location/brazilian_location.dart';
import 'package:happfest/core/location/location_providers.dart';
import 'package:happfest/design_system/components/app_form_fields.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';

/// Par de dropdowns Estado → Cidade usando a API pública do IBGE — resolve
/// `stateCodigoUf`/`cityCodigoIbge`, exigidos por `CustomerAddressRequest`
/// e `PartyRequest` mas sem busca própria na API HappFest.
class StateCityPicker extends ConsumerStatefulWidget {
  const StateCityPicker({required this.onChanged, super.key});

  /// Chamado sempre que o par muda; `null` enquanto a seleção estiver
  /// incompleta.
  final void Function(BrazilianState? state, BrazilianCity? city) onChanged;

  @override
  ConsumerState<StateCityPicker> createState() => _StateCityPickerState();
}

class _StateCityPickerState extends ConsumerState<StateCityPicker> {
  BrazilianState? _state;
  BrazilianCity? _city;

  void _onStateChanged(BrazilianState? state) {
    setState(() {
      _state = state;
      _city = null;
    });
    widget.onChanged(_state, _city);
  }

  void _onCityChanged(BrazilianCity? city) {
    setState(() => _city = city);
    widget.onChanged(_state, _city);
  }

  @override
  Widget build(BuildContext context) {
    final statesAsync = ref.watch(brazilianStatesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        statesAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) => const Text(
            'Não foi possível carregar a lista de estados.',
          ),
          data: (states) => AppDropdown<BrazilianState>(
            label: 'Estado',
            value: _state,
            items: [
              for (final state in states)
                DropdownMenuItem(value: state, child: Text(state.name)),
            ],
            onChanged: _onStateChanged,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_state != null)
          Consumer(
            builder: (context, ref, _) {
              final citiesAsync = ref.watch(
                brazilianCitiesProvider(_state!.code),
              );
              return citiesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, stackTrace) => const Text(
                  'Não foi possível carregar a lista de cidades.',
                ),
                data: (cities) => AppDropdown<BrazilianCity>(
                  label: 'Cidade',
                  value: _city,
                  items: [
                    for (final city in cities)
                      DropdownMenuItem(value: city, child: Text(city.name)),
                  ],
                  onChanged: _onCityChanged,
                ),
              );
            },
          ),
      ],
    );
  }
}
