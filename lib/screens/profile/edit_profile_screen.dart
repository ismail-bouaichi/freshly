import 'package:flutter/material.dart';

import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/shop.dart';

/// 17 · Edit Profile
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name, _email, _phone;
  late Set<String> _diet;
  bool _init = false;
  bool _saving = false;

  static const _diets = ['Vegetarian', 'Organic only', 'Gluten-free', 'Vegan', 'Low sugar'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final app = AppScope.read(context);
    _name = TextEditingController(text: app.name);
    _email = TextEditingController(text: app.email);
    _phone = TextEditingController(text: app.phone);
    _diet = {...app.diet};
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    AppScope.read(context).updateProfile(
      name: _name.text.trim().isEmpty ? 'Sara Amrani' : _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      diet: _diet,
    );
    Navigator.of(context).pop();
    showToast(context, 'Profile updated');
  }

  @override
  Widget build(BuildContext context) {
    final initials = _name.text.trim().split(RegExp(r'\s+')).take(2).map((w) => w.isEmpty ? '' : w[0].toUpperCase()).join();
    Widget field(String label, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ts(12, w: W.bold, c: AppColors.muted),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: TopBar(
                title: 'Edit profile',
                trailing: Pressable(
                  onTap: _save,
                  child: Center(
                    child: Text(
                      'Save',
                      style: ts(15, w: W.bold, c: AppColors.leafDark),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                children: staggered(stepMs: 60, [
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 108,
                          height: 108,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Hero(
                                tag: 'avatar',
                                child: Container(
                                  width: 104,
                                  height: 104,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(color: AppColors.lime, shape: BoxShape.circle),
                                  child: Text(
                                    initials.isEmpty ? '?' : initials,
                                    style: ts(34, w: W.black, c: AppColors.forest),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 2,
                                child: Entrance(
                                  delay: const Duration(milliseconds: 450),
                                  scale: 0.2,
                                  offset: Offset.zero,
                                  child: Pressable(
                                    onTap: () => showToast(context, 'Choose a photo from your library'),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColors.forest,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.cream, width: 3),
                                      ),
                                      child: const Ic(AppIcon.camera, size: 17, color: AppColors.lime),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Change photo',
                          style: ts(13, w: W.bold, c: AppColors.leafDark),
                        ),
                      ],
                    ),
                  ),
                  field(
                    'Full name',
                    AppTextField(icon: AppIcon.user, hint: 'Full name', controller: _name, onChanged: (_) => setState(() {})),
                  ),
                  field(
                    'Email',
                    AppTextField(
                      icon: AppIcon.mail,
                      hint: 'Email',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      trailing: const Pill('Verified', icon: AppIcon.check, size: 11, ph: 8, pv: 4),
                    ),
                  ),
                  field('Phone', AppTextField(icon: AppIcon.phone, hint: 'Phone', controller: _phone, keyboardType: TextInputType.phone)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dietary preferences', style: ts(15, w: W.black)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final d in _diets)
                            FilterPill(
                              label: d,
                              active: _diet.contains(d),
                              showCheck: true,
                              onTap: () => setState(() => _diet.contains(d) ? _diet.remove(d) : _diet.add(d)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ]).expand((w) => [w, const SizedBox(height: 16)]).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: PrimaryButton(label: 'Save changes', loading: _saving, onTap: _save),
            ),
          ],
        ),
      ),
    );
  }
}
