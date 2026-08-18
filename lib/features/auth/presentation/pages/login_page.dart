import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/components/app_form_layout.dart';
import 'package:happfest/design_system/components/app_text_field.dart';
import 'package:happfest/design_system/feedback/app_snackbar.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/auth/presentation/controllers/login_controller.dart';
import 'package:happfest/features/auth/presentation/controllers/login_state.dart';
import 'package:happfest/l10n/generated/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(loginControllerProvider);
    final isLoading = state is LoginLoading;

    ref.listen(loginControllerProvider, (previous, next) {
      switch (next) {
        case LoginSuccess():
          context.go('/');
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
              child: AppFormLayout(
                children: [
                  SvgPicture.asset(
                    'assets/images/happ_logo.svg',
                    height: 88,
                    semanticsLabel: l10n.appName,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: l10n.loginEmailLabel,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    enabled: !isLoading,
                  ),
                  AppTextField(
                    label: l10n.loginPasswordLabel,
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    enabled: !isLoading,
                    onSubmitted: (_) => _submit(),
                  ),
                  AppButton.confirm(
                    label: l10n.loginSubmitButton,
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
                    expanded: true,
                  ),
                  if (kDebugMode)
                    AppButton(
                      label: 'Pular login (debug)',
                      variant: AppButtonVariant.ghost,
                      expanded: true,
                      onPressed: () => context.go('/'),
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
