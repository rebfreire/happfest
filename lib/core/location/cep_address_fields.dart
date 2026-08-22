import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/location/brazilian_location.dart';
import 'package:happfest/core/location/location_providers.dart';
import 'package:happfest/core/location/state_city_picker.dart';
import 'package:happfest/design_system/components/app_text_field.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';

/// Campos de rua/bairro/CEP com preenchimento automático via ViaCEP — o
/// usuário digita só o CEP e rua/bairro/cidade/UF vêm prontos, sem precisar
/// escolher estado/cidade na mão. Se o CEP não for encontrado, cai para o
/// [StateCityPicker] manual.
class CepAddressFields extends ConsumerStatefulWidget {
  const CepAddressFields({
    required this.zipCodeController,
    required this.streetController,
    required this.neighborhoodController,
    required this.onLocationChanged,
    super.key,
  });

  final TextEditingController zipCodeController;
  final TextEditingController streetController;
  final TextEditingController neighborhoodController;

  /// `null` enquanto cidade/estado não estiverem resolvidos.
  final void Function(int? cityCodigoIbge, int? stateCodigoUf)
  onLocationChanged;

  @override
  ConsumerState<CepAddressFields> createState() => _CepAddressFieldsState();
}

class _CepAddressFieldsState extends ConsumerState<CepAddressFields> {
  var _isLookingUp = false;
  var _lookupFailed = false;
  String? _resolvedCityLabel;
  int? _cityCodigoIbge;
  int? _stateCodigoUf;

  void _notifyParent() {
    widget.onLocationChanged(_cityCodigoIbge, _stateCodigoUf);
  }

  Future<void> _onZipCodeChanged(String value) async {
    final digits = value.replaceAll(RegExp('[^0-9]'), '');
    if (digits.length != 8) {
      setState(() {
        _lookupFailed = false;
        _resolvedCityLabel = null;
        _cityCodigoIbge = null;
        _stateCodigoUf = null;
      });
      _notifyParent();
      return;
    }

    setState(() => _isLookingUp = true);
    final result = await ref.read(viaCepDataSourceProvider).lookup(digits);
    if (!mounted) return;
    setState(() => _isLookingUp = false);

    if (result == null) {
      setState(() {
        _lookupFailed = true;
        _resolvedCityLabel = null;
        _cityCodigoIbge = null;
        _stateCodigoUf = null;
      });
      _notifyParent();
      return;
    }

    widget.streetController.text = result.street;
    widget.neighborhoodController.text = result.neighborhood;
    setState(() {
      _lookupFailed = false;
      _resolvedCityLabel = '${result.cityName} - ${result.stateAbbreviation}';
      _cityCodigoIbge = result.cityCodigoIbge;
      _stateCodigoUf = result.stateCodigoUf;
    });
    _notifyParent();
  }

  void _onManualLocationChanged(BrazilianState? state, BrazilianCity? city) {
    setState(() {
      _cityCodigoIbge = city?.code;
      _stateCodigoUf = state?.code;
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'CEP (somente números)',
          controller: widget.zipCodeController,
          keyboardType: TextInputType.number,
          onChanged: (value) => unawaited(_onZipCodeChanged(value)),
        ),
        if (_isLookingUp) ...[
          const SizedBox(height: AppSpacing.sm),
          const LinearProgressIndicator(),
        ],
        if (_resolvedCityLabel != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('Cidade: $_resolvedCityLabel'),
        ],
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Rua',
          controller: widget.streetController,
          onChanged: (_) => _notifyParent(),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Bairro',
          controller: widget.neighborhoodController,
          onChanged: (_) => _notifyParent(),
        ),
        if (_lookupFailed) ...[
          const SizedBox(height: AppSpacing.md),
          const Text('CEP não encontrado — selecione a cidade manualmente.'),
          const SizedBox(height: AppSpacing.sm),
          StateCityPicker(onChanged: _onManualLocationChanged),
        ],
      ],
    );
  }
}
