/*
 * First-run language picker shown as the first onboarding page.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/config/app_constants.dart';
import 'package:mindful/config/locales.dart';
import 'package:mindful/core/extensions/ext_build_context.dart';
import 'package:mindful/l10n/generated/app_localizations.dart';
import 'package:mindful/providers/system/mindful_settings_provider.dart';

class LanguagePage extends ConsumerStatefulWidget {
  const LanguagePage({super.key});

  @override
  ConsumerState<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends ConsumerState<LanguagePage> {
  /// Auto-select the device language only once per app launch
  static bool _autoDetected = false;

  @override
  void initState() {
    super.initState();
    if (_autoDetected) return;
    _autoDetected = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final device =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      final current = ref.read(mindfulSettingsProvider).localeCode;
      if (current == AppConstants.defaultLocale && device != current) {
        ref.read(mindfulSettingsProvider.notifier).changeLocale(device);
      }
    });
  }

  /// Splits "Native (English)" into native and english names
  List<String> _names(String code) {
    final raw = Locales.knownLocales[code] ?? code;
    final i = raw.lastIndexOf(' (');
    if (i <= 0 || !raw.endsWith(')')) return [raw, ''];
    return [raw.substring(0, i), raw.substring(i + 2, raw.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    final selected =
        ref.watch(mindfulSettingsProvider.select((v) => v.localeCode));
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final codes = AppLocalizations.supportedLocales
        .map((e) => e.languageCode)
        .toSet()
        .toList();

    return Padding(
      padding: const EdgeInsets.only(top: 64, bottom: 112),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.language_rounded,
                  size: 30,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.locale.app_language_tile_title,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Language  •  زبان  •  भाषा  •  Idioma",
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          /// Languages
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemCount: codes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final code = codes[index];
                final isSelected = code == selected;
                final names = _names(code);

                return Material(
                  color: isSelected
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => ref
                        .read(mindfulSettingsProvider.notifier)
                        .changeLocale(code),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  names[0],
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? scheme.onPrimaryContainer
                                        : scheme.onSurface,
                                  ),
                                ),
                                if (names[1].isNotEmpty)
                                  Text(
                                    names[1],
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: isSelected ? scheme.primary : scheme.outline,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
