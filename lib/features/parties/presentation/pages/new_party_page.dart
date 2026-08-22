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
import 'package:happfest/features/account/domain/entities/customer_account.dart';
import 'package:happfest/features/account/presentation/controllers/account_providers.dart';
import 'package:happfest/features/parties/data/party_providers.dart';
import 'package:happfest/features/parties/presentation/controllers/party_providers.dart';
import 'package:intl/intl.dart';

class NewPartyPage extends ConsumerStatefulWidget {
  const NewPartyPage({super.key});

  @override
  ConsumerState<NewPartyPage> createState() => _NewPartyPageState();
}

class _NewPartyPageState extends ConsumerState<NewPartyPage> {
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _guestCountController = TextEditingController();

  int? _cityCodigoIbge;
  int? _stateCodigoUf;
  DateTime? _startDate;
  DateTime? _endDate;
  var _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _zipCodeController.dispose();
    _guestCountController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _streetController.text.trim().isNotEmpty &&
      _numberController.text.trim().isNotEmpty &&
      _neighborhoodController.text.trim().isNotEmpty &&
      _zipCodeController.text.trim().length == 8 &&
      int.tryParse(_guestCountController.text.trim()) != null &&
      _cityCodigoIbge != null &&
      _stateCodigoUf != null &&
      _startDate != null &&
      _endDate != null &&
      !_endDate!.isBefore(_startDate!);

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    final customerContext = await ref.read(accountContextProvider.future);
    if (customerContext is! Ok<CustomerAccount>) {
      if (mounted) {
        AppSnackbar.error(context, 'Não foi possível identificar sua conta.');
      }
      return;
    }

    setState(() => _isSaving = true);
    final result = await ref.read(createPartyUseCaseProvider)(
      customerId: customerContext.value.customerId,
      street: _streetController.text.trim(),
      number: _numberController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      cityCodigoIbge: _cityCodigoIbge!,
      stateCodigoUf: _stateCodigoUf!,
      zipCode: _zipCodeController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      guestCount: int.parse(_guestCountController.text.trim()),
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      complement: _complementController.text.trim().isEmpty
          ? null
          : _complementController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    switch (result) {
      case Ok():
        ref.invalidate(partiesProvider);
        AppSnackbar.success(context, 'Festa cadastrada.');
        context.pop();
      case Err(:final failure):
        AppSnackbar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return AppScaffold(
      title: 'Nova festa',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: AppFormLayout(
          children: [
            AppTextField(
              label: 'Nome da festa (opcional)',
              controller: _nameController,
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
            AppTextField(
              label: 'Número de convidados',
              controller: _guestCountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            OutlinedButton(
              onPressed: () => unawaited(_pickDate(isStart: true)),
              child: Text(
                _startDate == null
                    ? 'Data de início'
                    : 'Início: ${dateFormat.format(_startDate!)}',
              ),
            ),
            OutlinedButton(
              onPressed: () => unawaited(_pickDate(isStart: false)),
              child: Text(
                _endDate == null
                    ? 'Data de término'
                    : 'Término: ${dateFormat.format(_endDate!)}',
              ),
            ),
            AppButton.save(
              label: 'Salvar festa',
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
