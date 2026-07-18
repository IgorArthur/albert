import 'package:albert/features/profile/presentation/getx/profile_controller.dart';
import 'package:albert/features/utils/colors/app_colors.dart';
import 'package:albert/features/utils/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Language option model ──────────────────────────────────────────────────

class _LangOption {
  const _LangOption({
    required this.code,
    required this.label,
    required this.flag,
  });

  final String code;
  final String label;
  final String flag; // emoji flag
}

const _kLanguages = [
  _LangOption(code: 'en', label: 'English', flag: '🇺🇸'),
  _LangOption(code: 'pt', label: 'Português', flag: '🇧🇷'),
];

// ── Widget ─────────────────────────────────────────────────────────────────

class ProfileLanguageSelector extends StatelessWidget {
  const ProfileLanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ProfileController.to;

    return Obx(() {
      final currentCode = c.language.value;
      final current = _kLanguages.firstWhere(
        (l) => l.code == currentCode,
        orElse: () => _kLanguages.first,
      );

      return _LanguageDropdown(
        current: current,
        onChanged: (opt) => c.setLanguage(opt.code),
      );
    });
  }
}

// ── Custom dropdown ────────────────────────────────────────────────────────

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown({
    required this.current,
    required this.onChanged,
  });

  final _LangOption current;
  final ValueChanged<_LangOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonHideUnderline(
      child: DropdownButton<_LangOption>(
        value: current,
        isExpanded: true,
        dropdownColor: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.neutral60,
        ),
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
        // ── Selected item ─────────────────────────────────────────────────
        selectedItemBuilder: (context) => _kLanguages.map((lang) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.primary100.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppColors.primary100, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(lang.flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Text(lang.label).captionBold(color: AppColors.primary100),
              ],
            ),
          );
        }).toList(),
        // ── Menu items ────────────────────────────────────────────────────
        items: _kLanguages.map((lang) {
          final isSelected = lang.code == current.code;
          return DropdownMenuItem<_LangOption>(
            value: lang,
            child: Row(
              children: [
                Text(lang.flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Text(
                  lang.label,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primary100
                        : (isDark ? Colors.white : Colors.black),
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.primary100,
                    size: 18,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        onChanged: (opt) {
          if (opt != null) onChanged(opt);
        },
      ),
    );
  }
}
