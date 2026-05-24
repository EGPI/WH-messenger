import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_controller.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  static const routePath = '/signup';

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).register(
      name: _nameController.text,
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
                    const _SignupHeader(),
                    const SizedBox(height: 32),
                    AuthTextField(
                      controller: _nameController,
                      label: 'Name',
                      validator: _validateName,
                    ),
                    const SizedBox(height: 14),
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
                      label: 'Create account',
                      isLoading: isSubmitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed:
                      isSubmitting ? null : () => context.go('/login'),
                      child: const Text('Already have an account? Log in'),
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

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) return 'Name is required.';
    if (name.length < 2) return 'Name is too short.';

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return 'Email is required.';
    if (!email.contains('@')) return 'Enter a valid email.';

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) return 'Password is required.';
    if (password.length < 8) return 'Password must be at least 8 characters.';

    return null;
  }
}

class _SignupHeader extends StatelessWidget {
  const _SignupHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.person_add_alt_1_rounded,
            size: 34,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Create account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start using your chat app',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}