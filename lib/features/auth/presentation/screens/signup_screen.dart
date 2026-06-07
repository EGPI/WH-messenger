import 'dart:ui';

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
      body: Stack(
        children: [
          const _AnimatedAuthBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _SignupHeader(),
                        const SizedBox(height: 34),
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
                        const SizedBox(height: 24),
                        AuthPrimaryButton(
                          label: 'Create account',
                          isLoading: isSubmitting,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 18),
                        TextButton(
                          onPressed: isSubmitting
                              ? null
                              : () => context.go('/login'),
                          child: const Text('Already have an account? Log in'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }

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
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                const Color(0xFF42A5F5),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.28),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Create account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF102033),
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Start using your chat app',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF6B7A90),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AnimatedAuthBackground extends StatefulWidget {
  const _AnimatedAuthBackground();

  @override
  State<_AnimatedAuthBackground> createState() =>
      _AnimatedAuthBackgroundState();
}

class _AnimatedAuthBackgroundState extends State<_AnimatedAuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_AuthParticle> _particles;

  @override
  void initState() {
    super.initState();

    _particles = _createParticles();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_AuthParticle> _createParticles() {
    return const [
      _AuthParticle(x: 28, y: 80, radius: 4, speed: 0.55, opacity: 0.20),
      _AuthParticle(x: 74, y: 190, radius: 6, speed: 0.80, opacity: 0.16),
      _AuthParticle(x: 142, y: 120, radius: 3, speed: 0.65, opacity: 0.22),
      _AuthParticle(x: 218, y: 260, radius: 5, speed: 0.95, opacity: 0.14),
      _AuthParticle(x: 318, y: 160, radius: 7, speed: 0.70, opacity: 0.18),
      _AuthParticle(x: 366, y: 310, radius: 4, speed: 1.00, opacity: 0.20),
      _AuthParticle(x: 42, y: 410, radius: 5, speed: 0.75, opacity: 0.13),
      _AuthParticle(x: 114, y: 560, radius: 3, speed: 0.90, opacity: 0.22),
      _AuthParticle(x: 196, y: 480, radius: 6, speed: 0.60, opacity: 0.15),
      _AuthParticle(x: 280, y: 650, radius: 4, speed: 0.85, opacity: 0.19),
      _AuthParticle(x: 352, y: 720, radius: 6, speed: 0.70, opacity: 0.16),
      _AuthParticle(x: 24, y: 730, radius: 3, speed: 0.95, opacity: 0.22),
      _AuthParticle(x: 96, y: 330, radius: 7, speed: 0.58, opacity: 0.12),
      _AuthParticle(x: 165, y: 705, radius: 5, speed: 0.78, opacity: 0.17),
      _AuthParticle(x: 240, y: 70, radius: 4, speed: 0.68, opacity: 0.21),
      _AuthParticle(x: 332, y: 510, radius: 5, speed: 0.88, opacity: 0.15),
      _AuthParticle(x: 58, y: 635, radius: 6, speed: 0.73, opacity: 0.14),
      _AuthParticle(x: 132, y: 765, radius: 4, speed: 0.92, opacity: 0.20),
      _AuthParticle(x: 266, y: 382, radius: 3, speed: 0.82, opacity: 0.23),
      _AuthParticle(x: 388, y: 82, radius: 5, speed: 0.62, opacity: 0.18),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = Curves.easeInOutSine.transform(_controller.value);

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              final scaleX = width / 400;
              final scaleY = height / 800;

              final ellipse1X = (-100 + (10 * value)) * scaleX;
              final ellipse1Y = (-100 + (20 * value)) * scaleY;

              final ellipse2X = (250 + (-15 * value)) * scaleX;
              final ellipse2Y = (500 + (10 * value)) * scaleY;

              return Container(
                color: Colors.white,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ParticlePainter(
                          particles: _particles,
                          progress: _controller.value,
                        ),
                      ),
                    ),

                    // Exact MAUI Ellipse1 equivalent:
                    // Width 200, Height 200, TranslationX -100, TranslationY -100,
                    // moving to x -90, y -80 over 3000ms.
                    Positioned(
                      left: ellipse1X,
                      top: ellipse1Y,
                      child: _MauiStyleEllipse(
                        size: 200 * scaleX.clamp(0.85, 1.25),
                        opacity: 0.35,
                        center: const Alignment(-0.4, -0.4),
                        color: const Color(0xFF8C44DC),
                      ),
                    ),

                    // Exact MAUI Ellipse2 equivalent:
                    // Width 180, Height 180, TranslationX 250, TranslationY 500,
                    // moving to x 235, y 510 over 3000ms.
                    Positioned(
                      left: ellipse2X,
                      top: ellipse2Y,
                      child: _MauiStyleEllipse(
                        size: 180 * scaleX.clamp(0.85, 1.25),
                        opacity: 0.35,
                        center: const Alignment(0.4, 0.4),
                        color: const Color(0xFFFF3F72),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MauiStyleEllipse extends StatelessWidget {
  final double size;
  final double opacity;
  final Alignment center;
  final Color color;

  const _MauiStyleEllipse({
    required this.size,
    required this.opacity,
    required this.center,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: center,
              radius: 0.5,
              colors: [
                color,
                color.withValues(alpha: 0),
              ],
              stops: const [
                0.0,
                1.0,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthParticle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double opacity;

  const _AuthParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_AuthParticle> particles;
  final double progress;

  const _ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final scaleX = size.width / 400;
    final scaleY = size.height / 800;

    for (final particle in particles) {
      final rawY = particle.y - ((progress * 80 * particle.speed) % 800);
      final wrappedY = rawY < 0 ? rawY + 800 : rawY;

      paint.color = const Color(0xFF87CEEB).withValues(
        alpha: particle.opacity,
      );

      canvas.drawCircle(
        Offset(
          particle.x * scaleX,
          wrappedY * scaleY,
        ),
        particle.radius * scaleX.clamp(0.85, 1.25),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}