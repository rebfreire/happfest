import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/components/app_text_field.dart';
import 'package:happfest/design_system/feedback/app_snackbar.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/auth/data/auth_providers.dart';
import 'package:happfest/features/auth/presentation/controllers/login_controller.dart';
import 'package:happfest/features/auth/presentation/controllers/login_state.dart';
import 'package:happfest/l10n/generated/app_localizations.dart';

/// Login por email/senha. [returnTo] é a rota que o usuário tentava
/// acessar quando foi levado aqui (ex.: `/checkout`, ao tocar "Finalizar
/// compra" sem estar logado) — navegado de volta ao concluir o login. Sem
/// [returnTo], segue para a Home: o app é navegável sem login, só pede
/// autenticação quando uma ação realmente exige (finalizar compra, ver
/// perfil/festas).
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.returnTo});

  final String? returnTo;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    unawaited(
      ref
          .read(loginControllerProvider.notifier)
          .submit(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
    );
  }

  Future<void> _forgotPassword() async {
    final email = await showDialog<String>(
      context: context,
      builder: (context) =>
          _ForgotPasswordDialog(initialEmail: _emailController.text.trim()),
    );
    if (email == null || !mounted) return;

    final result = await ref.read(requestPasswordResetUseCaseProvider)(email);
    if (!mounted) return;
    switch (result) {
      case Ok():
        AppSnackbar.success(
          context,
          'Enviamos um link de recuperação para $email.',
        );
      case Err(:final failure):
        AppSnackbar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(loginControllerProvider);
    final isLoading = state is LoginLoading;

    ref.listen(loginControllerProvider, (previous, next) {
      switch (next) {
        case LoginSuccess():
          context.go(widget.returnTo ?? '/');
        case LoginFailure(:final failure):
          AppSnackbar.error(context, failure.message);
        case LoginIdle():
        case LoginLoading():
          break;
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/happ_logo.svg',
                      height: 64,
                      semanticsLabel: l10n.appName,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.loginTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.loginSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.loginEmailLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppTextField(
                    label: '',
                    hint: l10n.loginEmailHint,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.loginPasswordLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppTextField(
                    label: '',
                    hint: l10n.loginPasswordHint,
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    enabled: !isLoading,
                    onSubmitted: (_) => _submit(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () => unawaited(_forgotPassword()),
                      child: Text(l10n.loginForgotPassword),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton.confirm(
                    label: l10n.loginSubmitButton,
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
                    expanded: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(text: l10n.loginNoAccountQuestion),
                          TextSpan(
                            text: l10n.loginCreateAccountLink,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = isLoading
                                  ? null
                                  : () => context.push(
                                      '/cadastro',
                                      extra: widget.returnTo,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: 'Pular login (debug)',
                      variant: AppButtonVariant.ghost,
                      expanded: true,
                      onPressed: () => context.go(widget.returnTo ?? '/'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final _emailController = TextEditingController(
    text: widget.initialEmail,
  );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recuperar senha'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enviaremos um link de recuperação para o seu email.'),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
        ],
      ),
      actions: [
        AppButton.cancel(
          label: 'Cancelar',
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton.confirm(
          label: 'Enviar',
          onPressed: () =>
              Navigator.of(context).pop(_emailController.text.trim()),
        ),
      ],
    );
  }
}
