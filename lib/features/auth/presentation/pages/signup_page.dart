import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/core/location/cep_address_fields.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/components/app_form_layout.dart';
import 'package:happfest/design_system/components/app_text_field.dart';
import 'package:happfest/design_system/feedback/app_snackbar.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/auth/presentation/controllers/signup_controller.dart';
import 'package:happfest/features/auth/presentation/controllers/signup_state.dart';

/// Cadastro de novo cliente (`POST /customers`, público). Desde que o
/// backend provisiona automaticamente uma subconta financeira Asaas por
/// cliente, o formulário coleta, em 3 etapas, tudo que a API exige: dados
/// de acesso, dados pessoais (CPF/telefone/nascimento/renda) e endereço.
/// Ao concluir, faz login automático com as mesmas credenciais e segue
/// para [returnTo] — a rota que o usuário tentava acessar quando foi
/// levado ao login (ex.: `/checkout`), ou a Home quando chegou aqui sem um
/// destino específico.
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key, this.returnTo});

  final String? returnTo;

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

enum _SignupStep { access, personal, address }

class _SignupPageState extends ConsumerState<SignupPage> {
  _SignupStep _step = _SignupStep.access;

  // Dados de acesso.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Dados pessoais.
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _incomeController = TextEditingController();
  DateTime? _birthDate;

  // Endereço.
  final _zipCodeController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  int? _cityCodigoIbge;
  int? _stateCodigoUf;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _incomeController.dispose();
    _zipCodeController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  String _onlyDigits(String value) => value.replaceAll(RegExp('[^0-9]'), '');

  bool get _isAccessStepValid =>
      _nameController.text.trim().isNotEmpty &&
      _emailController.text.trim().contains('@') &&
      _passwordController.text.length >= 6;

  bool get _isPersonalStepValid {
    final birthDate = _birthDate;
    if (birthDate == null || birthDate.isAfter(DateTime.now())) return false;
    final income = double.tryParse(
      _incomeController.text.trim().replaceAll(',', '.'),
    );
    return _onlyDigits(_cpfController.text).length == 11 &&
        _onlyDigits(_phoneController.text).isNotEmpty &&
        income != null &&
        income > 0;
  }

  bool get _isAddressStepValid =>
      _streetController.text.trim().isNotEmpty &&
      _numberController.text.trim().isNotEmpty &&
      _neighborhoodController.text.trim().isNotEmpty &&
      _onlyDigits(_zipCodeController.text).length == 8 &&
      _cityCodigoIbge != null &&
      _stateCodigoUf != null;

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
      helpText: 'Data de nascimento',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  String _formatDate(DateTime date) {
    String pad2(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${pad2(date.month)}-${pad2(date.day)}';
  }

  void _goNext() {
    setState(() {
      _step = switch (_step) {
        _SignupStep.access => _SignupStep.personal,
        _SignupStep.personal => _SignupStep.address,
        _SignupStep.address => _SignupStep.address,
      };
    });
  }

  void _goBack() {
    setState(() {
      _step = switch (_step) {
        _SignupStep.access => _SignupStep.access,
        _SignupStep.personal => _SignupStep.access,
        _SignupStep.address => _SignupStep.personal,
      };
    });
  }

  void _submit() {
    unawaited(
      ref
          .read(signupControllerProvider.notifier)
          .submit(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            cpf: _onlyDigits(_cpfController.text),
            phone: _onlyDigits(_phoneController.text),
            birthDate: _formatDate(_birthDate!),
            incomeValue: double.parse(
              _incomeController.text.trim().replaceAll(',', '.'),
            ),
            street: _streetController.text.trim(),
            number: _numberController.text.trim(),
            neighborhood: _neighborhoodController.text.trim(),
            cityCodigoIbge: _cityCodigoIbge!,
            stateCodigoUf: _stateCodigoUf!,
            zipCode: _onlyDigits(_zipCodeController.text),
            complement: _complementController.text.trim().isEmpty
                ? null
                : _complementController.text.trim(),
          ),
    );
  }

  /// A API exige e-mail verificado antes de permitir login — não há
  /// auto-login após o cadastro (ver `AuthRepository.signup`). Avisa o
  /// usuário e manda para o login, de onde ele entra depois de confirmar
  /// o e-mail.
  Future<void> _showAccountCreatedDialog() async {
    final email = _emailController.text.trim();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Conta criada!'),
        content: Text(
          'Enviamos um e-mail de confirmação para $email. Verifique sua '
          'caixa de entrada e confirme antes de entrar.',
        ),
        actions: [
          AppButton.confirm(
            label: 'Ir para o login',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
    if (!mounted) return;
    context.go('/login', extra: widget.returnTo);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupControllerProvider);
    final isLoading = state is SignupLoading;

    ref.listen(signupControllerProvider, (previous, next) {
      switch (next) {
        case SignupSuccess():
          unawaited(_showAccountCreatedDialog());
        case SignupFailure(:final failure):
          AppSnackbar.error(context, failure.message);
        case SignupIdle():
        case SignupLoading():
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        leading: BackButton(
          onPressed: _step == _SignupStep.access
              ? () => context.pop()
              : _goBack,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StepIndicator(step: _step),
                  const SizedBox(height: AppSpacing.lg),
                  switch (_step) {
                    _SignupStep.access => _buildAccessStep(isLoading),
                    _SignupStep.personal => _buildPersonalStep(isLoading),
                    _SignupStep.address => _buildAddressStep(isLoading),
                  },
                  const SizedBox(height: AppSpacing.lg),
                  switch (_step) {
                    _SignupStep.access => AppButton.confirm(
                      label: 'Avançar',
                      onPressed: _isAccessStepValid && !isLoading
                          ? _goNext
                          : null,
                      expanded: true,
                    ),
                    _SignupStep.personal => AppButton.confirm(
                      label: 'Avançar',
                      onPressed: _isPersonalStepValid && !isLoading
                          ? _goNext
                          : null,
                      expanded: true,
                    ),
                    _SignupStep.address => AppButton.confirm(
                      label: 'Criar conta',
                      isLoading: isLoading,
                      onPressed: _isAddressStepValid && !isLoading
                          ? _submit
                          : null,
                      expanded: true,
                    ),
                  },
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessStep(bool isLoading) {
    return AppFormLayout(
      children: [
        AppTextField(
          label: 'Nome completo',
          controller: _nameController,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          enabled: !isLoading,
          onChanged: (_) => setState(() {}),
        ),
        AppTextField(
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          enabled: !isLoading,
          onChanged: (_) => setState(() {}),
        ),
        AppTextField(
          label: 'Senha',
          hint: 'Mínimo de 6 caracteres',
          controller: _passwordController,
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          enabled: !isLoading,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPersonalStep(bool isLoading) {
    return AppFormLayout(
      children: [
        AppTextField(
          label: 'CPF',
          hint: 'Somente números',
          controller: _cpfController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
          onChanged: (_) => setState(() {}),
        ),
        AppTextField(
          label: 'Telefone',
          hint: 'Somente números, com DDD',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.telephoneNumber],
          enabled: !isLoading,
          onChanged: (_) => setState(() {}),
        ),
        InkWell(
          onTap: isLoading ? null : () => unawaited(_pickBirthDate()),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Data de nascimento',
            ),
            child: Text(
              _birthDate == null
                  ? 'Selecionar data'
                  : _formatDate(_birthDate!),
            ),
          ),
        ),
        AppTextField(
          label: 'Renda mensal',
          hint: 'Ex.: 3500.00',
          controller: _incomeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          enabled: !isLoading,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildAddressStep(bool isLoading) {
    return AppFormLayout(
      children: [
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
          enabled: !isLoading,
          onChanged: (_) => setState(() {}),
        ),
        AppTextField(
          label: 'Complemento (opcional)',
          controller: _complementController,
          enabled: !isLoading,
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final _SignupStep step;

  @override
  Widget build(BuildContext context) {
    const labels = ['Dados de acesso', 'Dados pessoais', 'Endereço'];
    final currentIndex = _SignupStep.values.indexOf(step);
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Divider(
                color: i <= currentIndex
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
              ),
            ),
          CircleAvatar(
            radius: 12,
            backgroundColor: i <= currentIndex
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            child: Text(
              '${i + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
