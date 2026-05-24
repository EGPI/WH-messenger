import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_controller.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const routePath = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted || !success) return;

    context.go('/conversations');
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(
      authControllerProvider.select((state) => state.isSubmitting),
    );

    ref.listen(authControllerProvider.select((state) => state.errorMessage),
            (previous, next) {
          if (next == null || next == previous) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next)),
          );
        });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _LoginHeader(),
                    const SizedBox(height: 32),
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 22),
                    AuthPrimaryButton(
                      label: 'Log in',
                      isLoading: isSubmitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () => context.go('/signup'),
                      child: const Text('Create a new account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return 'Email is required.';
    if (!email.contains('@')) return 'Enter a valid email.';

    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Password is required.';
    return null;
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.chat_bubble_rounded,
            size: 34,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Log in to continue chatting',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}