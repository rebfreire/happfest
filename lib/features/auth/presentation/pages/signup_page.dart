import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/components/app_form_layout.dart';
import 'package:happfest/design_system/components/app_text_field.dart';
import 'package:happfest/design_system/feedback/app_snackbar.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/auth/presentation/controllers/signup_controller.dart';
import 'package:happfest/features/auth/presentation/controllers/signup_state.dart';

/// Cadastro de novo cliente (`POST /customers`, público). Ao concluir, faz
/// login automático com as mesmas credenciais e segue para [returnTo] — a
/// rota que o usuário tentava acessar quando foi levado ao login (ex.:
/// `/checkout`), ou a Home quando chegou aqui sem um destino específico.
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key, this.returnTo});

  final String? returnTo;

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    unawaited(
      ref
          .read(signupControllerProvider.notifier)
          .submit(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            cpf: _cpfController.text.trim(),
            phone: _phoneController.text.trim(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupControllerProvider);
    final isLoading = state is SignupLoading;

    ref.listen(signupControllerProvider, (previous, next) {
      switch (next) {
        case SignupSuccess():
          context.go(widget.returnTo ?? '/');
        case SignupFailure(:final failure):
          AppSnackbar.error(context, failure.message);
        case SignupIdle():
        case SignupLoading():
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AppFormLayout(
                children: [
                  AppTextField(
                    label: 'Nome completo',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    enabled: !isLoading,
                  ),
                  AppTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    enabled: !isLoading,
                  ),
                  AppTextField(
                    label: 'Senha',
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    enabled: !isLoading,
                  ),
                  AppTextField(
                    label: 'CPF',
                    hint: 'Somente números',
                    controller: _cpfController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                  ),
                  AppTextField(
                    label: 'Telefone',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    enabled: !isLoading,
                    onSubmitted: (_) => _submit(),
                  ),
                  AppButton.confirm(
                    label: 'Criar conta',
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
                    expanded: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
