import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/location/cep_address_fields.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/components/app_form_layout.dart';
import 'package:happfest/design_system/components/app_scaffold.dart';
import 'package:happfest/design_system/components/app_text_field.dart';
import 'package:happfest/design_system/feedback/app_snackbar.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/account/data/account_providers.dart';
import 'package:happfest/features/account/presentation/controllers/account_providers.dart';

class NewAddressPage extends ConsumerStatefulWidget {
  const NewAddressPage({super.key});

  @override
  ConsumerState<NewAddressPage> createState() => _NewAddressPageState();
}

class _NewAddressPageState extends ConsumerState<NewAddressPage> {
  final _labelController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _zipCodeController = TextEditingController();

  int? _cityCodigoIbge;
  int? _stateCodigoUf;
  var _isSaving = false;

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _labelController.text.trim().isNotEmpty &&
      _streetController.text.trim().isNotEmpty &&
      _numberController.text.trim().isNotEmpty &&
      _neighborhoodController.text.trim().isNotEmpty &&
      _zipCodeController.text.trim().length == 8 &&
      _cityCodigoIbge != null &&
      _stateCodigoUf != null;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final result = await ref.read(createAddressUseCaseProvider)(
      label: _labelController.text.trim(),
      street: _streetController.text.trim(),
      number: _numberController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      cityCodigoIbge: _cityCodigoIbge!,
      stateCodigoUf: _stateCodigoUf!,
      zipCode: _zipCodeController.text.trim(),
      complement: _complementController.text.trim().isEmpty
          ? null
          : _complementController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    switch (result) {
      case Ok():
        ref.invalidate(accountAddressesProvider);
        AppSnackbar.success(context, 'Endereço cadastrado.');
        context.pop();
      case Err(:final failure):
        AppSnackbar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Novo endereço',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: AppFormLayout(
          children: [
            AppTextField(
              label: 'Nome (ex.: Casa, Trabalho)',
              controller: _labelController,
              onChanged: (_) => setState(() {}),
            ),
            CepAddressFields(
              zipCodeController: _zipCodeController,
              streetController: _streetController,
              neighborhoodController: _neighborhoodController,
              onLocationChanged: (cityCode, stateCode) => setState(() {
                _cityCodigoIbge = cityCode;
                _stateCodigoUf = stateCode;
              }),
            ),
            AppTextField(
              label: 'Número',
              controller: _numberController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            AppTextField(
              label: 'Complemento (opcional)',
              controller: _complementController,
            ),
            AppButton.save(
              label: 'Salvar endereço',
              isLoading: _isSaving,
              onPressed: _isValid && !_isSaving
                  ? () => unawaited(_save())
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
