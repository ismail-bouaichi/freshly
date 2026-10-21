import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/produce.dart';
import '../../core/svg_path.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/shop.dart';

/// 05 · Sign In
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController(text: 'sara@freshly.app');
  final _password = TextEditingController(text: 'freshpicks');
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.shell, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: staggered(stepMs: 55, [
              const AuthHero(),
              const SizedBox(height: 8),
              Text('Welcome back', style: ts(30, w: W.black, ls: -0.8)),
              Text('Sign in to get farm-fresh produce delivered today.', style: ts(15, c: AppColors.muted, lh: 22)),
              const SizedBox(height: 4),
              AppTextField(
                icon: AppIcon.mail,
                hint: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              AppTextField(
                icon: AppIcon.lock,
                hint: 'Password',
                controller: _password,
                obscure: _obscure,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signIn(),
                trailing: Pressable(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Ic(_obscure ? AppIcon.eye : AppIcon.eyeOff, size: 20, color: AppColors.muted),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Pressable(
                  onTap: () => showToast(context, 'Reset link sent to ${_email.text}'),
                  child: Text(
                    'Forgot password?',
                    style: ts(13, w: W.bold, c: AppColors.leafDark),
                  ),
                ),
              ),
              PrimaryButton(label: 'Sign in', loading: _loading, onTap: _signIn),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.line)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or continue with',
                      style: ts(13, w: W.medium, c: AppColors.muted),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.line)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      label: 'Phone',
                      icon: AppIcon.phone,
                      onTap: () => showToast(context, 'We sent a code to your phone'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlineButton(
                      label: 'Guest',
                      icon: AppIcon.user,
                      onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(Routes.shell, (_) => false),
                    ),
                  ),
                ],
              ),
              Pressable(
                onTap: () => Navigator.of(context).pushReplacementNamed(Routes.signUp),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'New to Freshly? ',
                        children: [
                          TextSpan(
                            text: 'Create account',
                            style: ts(14, w: W.bold, c: AppColors.leafDark),
                          ),
                        ],
                      ),
                      style: ts(14, w: W.medium, c: AppColors.muted),
                    ),
                  ),
                ),
              ),
            ]).expand((w) => [w, const SizedBox(height: 14)]).toList(),
          ),
        ),
      ),
    );
  }
}

/// Dark produce banner at the top of Sign In.
class AuthHero extends StatelessWidget {
  const AuthHero({super.key});

  static const _items = [
    (Produce.basil, 72.0, 272.0, 4.0, -18.0),
    (Produce.strawberry, 86.0, 20.0, 96.0, 14.0),
    (Produce.lemon, 84.0, 236.0, 104.0, -14.0),
    (Produce.avocado, 118.0, 116.0, 72.0, -6.0),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        height: 176,
        color: AppColors.forest,
        child: LayoutBuilder(
          builder: (context, c) {
            final k = c.maxWidth / 342;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 160 * k,
                  top: -60,
                  child: Dot(size: 240, color: AppColors.lime.withValues(alpha: 0.1)),
                ),
                Positioned(left: -40, top: 90, child: Dot(size: 150, color: AppColors.leaf.withValues(alpha: 0.18))),
                const Positioned(left: 22, top: 22, child: FreshlyLogo(size: 30)),
                for (var i = 0; i < _items.length; i++)
                  Positioned(
                    left: _items[i].$3 * k,
                    top: _items[i].$4,
                    child: Entrance(
                      delay: Duration(milliseconds: 150 + i * 90),
                      scale: 0.3,
                      rotate: i.isOdd ? 16 : -16,
                      offset: const Offset(0, 30),
                      child: Bob(
                        phase: i * 0.25,
                        amplitude: 5,
                        child: Transform.rotate(
                          angle: figmaRot(_items[i].$5),
                          child: ProduceArt(_items[i].$1, size: _items[i].$2),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
