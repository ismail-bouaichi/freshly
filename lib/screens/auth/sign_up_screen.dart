import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/produce.dart';
import '../../core/svg_path.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';
import '../../widgets/shop.dart';

/// 12 · Sign Up — live email check, password strength meter, preference chips.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _terms = false;
  bool _loading = false;
  final Set<Category> _loves = {Category.fruits, Category.veggies};

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  int get _strength {
    final p = _password.text;
    if (p.isEmpty) return 0;
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s.clamp(1, 4);
  }

  bool get _valid => _name.text.trim().isNotEmpty && _emailRe.hasMatch(_email.text.trim()) && _password.text.length >= 6 && _terms;

  Future<void> _create() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final app = AppScope.read(context);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    app.updateProfile(name: _name.text.trim(), email: _email.text.trim(), phone: app.phone, diet: app.diet);
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.shell, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final strength = _strength;
    const labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    const colors = [AppColors.line, AppColors.berry, AppColors.gold, AppColors.leaf, AppColors.leaf];
    final emailOk = _emailRe.hasMatch(_email.text.trim());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: staggered(stepMs: 55, [
              Row(
                children: [
                  RoundButton(icon: AppIcon.chevronLeft, onTap: () => Navigator.of(context).maybePop(), tooltip: 'Back'),
                  const Spacer(),
                  const PageDots(count: 2, index: 0),
                ],
              ),
              SizedBox(
                height: 100,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create account', style: ts(30, w: W.black, ls: -0.8)),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 236,
                          child: Text(
                            'Join 50k+ neighbours eating fresh, local produce every week.',
                            style: ts(15, c: AppColors.muted, lh: 22),
                          ),
                        ),
                      ],
                    ),
                    for (final (i, f) in const [
                      (Produce.basil, 56.0, -2.0, -6.0, -18.0),
                      (Produce.carrot, 74.0, 46.0, 18.0, 24.0),
                      (Produce.strawberry, 62.0, 4.0, 44.0, -12.0),
                    ].indexed)
                      Positioned(
                        right: f.$3,
                        top: f.$4,
                        child: Entrance(
                          delay: Duration(milliseconds: 200 + i * 100),
                          scale: 0.3,
                          rotate: i.isOdd ? 14 : -14,
                          offset: Offset.zero,
                          child: Bob(
                            phase: i * 0.3,
                            amplitude: 5,
                            child: Transform.rotate(
                              angle: figmaRot(f.$5),
                              child: ProduceArt(f.$1, size: f.$2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              AppTextField(
                icon: AppIcon.user,
                hint: 'Full name',
                controller: _name,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.next,
              ),
              AppTextField(
                icon: AppIcon.mail,
                hint: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.next,
                trailing: AnimatedScale(
                  scale: emailOk ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  curve: kGentle,
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.leaf, shape: BoxShape.circle),
                    child: const Ic(AppIcon.check, size: 13, color: AppColors.white),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    icon: AppIcon.lock,
                    hint: 'Password (6+ characters)',
                    controller: _password,
                    obscure: _obscure,
                    onChanged: (_) => setState(() {}),
                    trailing: Pressable(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Ic(_obscure ? AppIcon.eye : AppIcon.eyeOff, size: 20, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (var i = 0; i < 4; i++)
                        Expanded(
                          child: Container(
                            height: 5,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(3)),
                            alignment: Alignment.centerLeft,
                            child: AnimatedFractionallySizedBox(
                              duration: Duration(milliseconds: 260 + i * 60),
                              curve: Curves.easeOutCubic,
                              widthFactor: i < strength ? 1 : 0,
                              child: Container(
                                decoration: BoxDecoration(color: colors[strength], borderRadius: BorderRadius.circular(3)),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 52,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            labels[strength],
                            key: ValueKey(strength),
                            textAlign: TextAlign.right,
                            style: ts(12, w: W.bold, c: strength >= 3 ? AppColors.leafDark : colors[strength]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('What do you love?', style: ts(15, w: W.black)),
                      ),
                      Text(
                        'Pick any',
                        style: ts(12, w: W.medium, c: AppColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in Category.values)
                        CategoryChip(
                          label: c.label,
                          produce: c.art,
                          active: _loves.contains(c),
                          onTap: () => setState(() => _loves.contains(c) ? _loves.remove(c) : _loves.add(c)),
                        ),
                    ],
                  ),
                ],
              ),
              Pressable(
                scale: 0.98,
                onTap: () => setState(() => _terms = !_terms),
                child: Row(
                  children: [
                    CheckBoxBox(value: _terms),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'I agree to the ',
                          children: [
                            TextSpan(
                              text: 'Terms',
                              style: ts(13, w: W.bold),
                            ),
                            const TextSpan(text: ' & '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: ts(13, w: W.bold),
                            ),
                          ],
                        ),
                        style: ts(13, w: W.medium, c: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ),
              PrimaryButton(label: 'Create account', loading: _loading, onTap: _valid ? _create : null),
              Pressable(
                onTap: () => Navigator.of(context).pushReplacementNamed(Routes.signIn),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      children: [
                        TextSpan(
                          text: 'Sign in',
                          style: ts(14, w: W.bold, c: AppColors.leafDark),
                        ),
                      ],
                    ),
                    style: ts(14, w: W.medium, c: AppColors.muted),
                  ),
                ),
              ),
            ]).expand((w) => [w, const SizedBox(height: 18)]).toList(),
          ),
        ),
      ),
    );
  }
}
