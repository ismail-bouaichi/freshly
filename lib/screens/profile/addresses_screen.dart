import 'package:flutter/material.dart';

import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/vector_art.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';
import '../../widgets/shop.dart';

/// 19 · Addresses
class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  static final List<VShape> _mini = [
    vr(0, 0, 342, 150, fill: const Color(0xFFE9EEE3)),
    vr(200, 86, 90, 50, rx: 12, fill: const Color(0xFFCDE7C5)),
    vp('M0 40H342M0 110H342M70 0V150M180 0V150M300 0V150', stroke: const Color(0xFFFFFFFF), sw: 12),
    vp('M0 75H342M125 0V150M240 0V150', stroke: const Color(0xCCFFFFFF), sw: 5),
    vr(86, 52, 26, 44, rx: 6, fill: const Color(0xFFDCE3D4)),
    vr(250, 52, 38, 16, rx: 6, fill: const Color(0xFFDCE3D4)),
    vr(10, 52, 48, 16, rx: 6, fill: const Color(0xFFDCE3D4)),
  ];

  static AppIcon _icon(String k) => switch (k) {
    'home' => AppIcon.home,
    'work' => AppIcon.briefcase,
    'heart' => AppIcon.heart,
    _ => AppIcon.pin,
  };

  Future<void> _add(BuildContext context) =>
      showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => const _NewAddressSheet());

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            TopBar(
              title: 'Addresses',
              trailing: RoundButton(
                icon: AppIcon.plus,
                bg: AppColors.forest,
                fg: AppColors.lime,
                tooltip: 'Add address',
                onTap: () => _add(context),
              ),
            ),
            const SizedBox(height: 16),
            Entrance(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 150,
                  child: LayoutBuilder(
                    builder: (context, c) {
                      return Stack(
                        children: [
                          VectorArt(_mini, viewBox: const Size(342, 150), width: c.maxWidth, height: 150),
                          Center(child: Pulse(size: 72, color: AppColors.lime.withValues(alpha: 0.6))),
                          Center(
                            child: Entrance(
                              delay: const Duration(milliseconds: 150),
                              offset: const Offset(0, -40),
                              scale: 0.6,
                              child: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.forest,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.white, width: 3),
                                ),
                                child: Ic(_icon(app.currentAddress.icon), size: 20, color: AppColors.lime),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (final (i, a) in app.addresses.indexed)
              Padding(
                key: ValueKey(a.id),
                padding: const EdgeInsets.only(bottom: 12),
                child: Entrance(
                  delay: Entrance.step(i, startMs: 120, stepMs: 70),
                  child: _AddressCard(
                    address: a,
                    selected: a.id == app.defaultAddress,
                    icon: _icon(a.icon),
                    onTap: () => app.setDefaultAddress(a.id),
                  ),
                ),
              ),
            Entrance(
              delay: const Duration(milliseconds: 400),
              child: Pressable(
                scale: 0.98,
                onTap: () => _add(context),
                child: DashedBorder(
                  color: AppColors.leaf,
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Ic(AppIcon.plus, size: 18, color: AppColors.leafDark),
                        const SizedBox(width: 8),
                        Text(
                          'Add new address',
                          style: ts(15, w: W.bold, c: AppColors.leafDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.selected, required this.icon, required this.onTap});
  final Address address;
  final bool selected;
  final AppIcon icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    scale: 0.98,
    onTap: onTap,
    child: SoftCard(
      padding: const EdgeInsets.all(14),
      radius: 22,
      border: selected ? AppColors.forest : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBox(icon, bg: address.tint, fg: address.color, size: 46, iconSize: 22, radius: 16),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(address.label, style: ts(15, w: W.bold)),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      child: selected
                          ? const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Pill('Default', bg: AppColors.lime, fg: AppColors.forest, size: 10, ph: 8, pv: 3),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  address.lines,
                  style: ts(13, w: W.medium, c: AppColors.muted, lh: 19),
                ),
              ],
            ),
          ),
          Column(
            children: [
              RadioDot(selected: selected),
              const SizedBox(height: 14),
              Pressable(
                onTap: () => showToast(context, 'Editing ${address.label}'),
                child: const Ic(AppIcon.pencil, size: 16, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// Owns its controllers so they outlive the sheet's closing animation.
class _NewAddressSheet extends StatefulWidget {
  const _NewAddressSheet();
  @override
  State<_NewAddressSheet> createState() => _NewAddressSheetState();
}

class _NewAddressSheetState extends State<_NewAddressSheet> {
  final _label = TextEditingController();
  final _street = TextEditingController();

  @override
  void dispose() {
    _label.dispose();
    _street.dispose();
    super.dispose();
  }

  void _save() {
    if (_street.text.trim().isEmpty) {
      showToast(context, 'Add a street address first');
      return;
    }
    AppScope.read(context).addAddress(_label.text.trim().isEmpty ? 'New place' : _label.text.trim(), _street.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SheetHandle(),
        const SizedBox(height: 16),
        Text('New address', style: ts(22, w: W.black)),
        const SizedBox(height: 16),
        AppTextField(
          icon: AppIcon.pencil,
          hint: 'Label (e.g. Gym, Studio)',
          controller: _label,
          autofocus: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        AppTextField(
          icon: AppIcon.pin,
          hint: 'Street, number, apartment',
          controller: _street,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 18),
        PrimaryButton(label: 'Save address', onTap: _save),
      ],
    ),
  );
}
