import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../../l10n/l10n.dart';

/// Label-above text field (larger, easier to read than floating labels).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.icon,
    this.suffix,
    this.errorText,
    this.helperText,
    this.obscure = false,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.requiredMark = false,
    this.autofillHints,
    this.enabled = true,
    this.trailingLabel,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final Widget? suffix;
  final String? errorText;
  final String? helperText;
  final bool obscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool requiredMark;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final Widget? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        FieldLabel(label, requiredMark: requiredMark, trailing: trailingLabel),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          obscureText: obscure,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: obscure ? 1 : maxLines,
          minLines: minLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          enabled: enabled,
          style: const TextStyle(fontSize: 16, color: AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, size: 20),
            suffixIcon: suffix,
            errorText: errorText,
            helperText: helperText,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.requiredMark = false, this.trailing});

  final String text;
  final bool requiredMark;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              text: text,
              children: [
                if (requiredMark)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
            style: AppText.label,
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Styled dropdown with a label on top.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
    this.hint,
    this.showLabel = true,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final IconData? icon;
  final String? hint;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final field = DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      borderRadius: BorderRadius.circular(14),
      dropdownColor: Colors.white,
      menuMaxHeight: 360,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
      style: const TextStyle(fontSize: 16, color: AppColors.text),
      hint: hint == null ? null : Text(hint!, style: const TextStyle(color: AppColors.textSubtle)),
      decoration: InputDecoration(prefixIcon: icon == null ? null : Icon(icon, size: 20)),
    );
    if (!showLabel) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [FieldLabel(label), const SizedBox(height: 8), field],
    );
  }
}

/// Search box used on list screens.
class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.controller, required this.onChanged, this.hint});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, v, _) => TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 16),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hint ?? context.l10n.searchHint,
          prefixIcon: const Icon(Icons.search_rounded, size: 22),
          suffixIcon: v.text.isEmpty
              ? null
              : IconButton(
                  tooltip: context.l10n.clear,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
        ),
      ),
    );
  }
}

/// Number stepper ( − 20 + ) used for delay / limits.
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    this.step = 1,
    this.suffix,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, int next, String tip) {
      final enabled = next >= min && next <= max;
      return Tooltip(
        message: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? () => onChanged(next) : null,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: enabled ? AppColors.primaryTint : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: enabled ? AppColors.primary : AppColors.disabledFg),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove_rounded, value - step, context.l10n.decrease),
          SizedBox(
            width: 92,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (c, a) => SlideTransition(
                position: Tween(begin: const Offset(0, .4), end: Offset.zero).animate(a),
                child: FadeTransition(opacity: a, child: c),
              ),
              child: Text(
                suffix == null ? '$value' : '$value $suffix',
                key: ValueKey(value),
                textAlign: TextAlign.center,
                style: AppText.mono.copyWith(fontSize: 17),
              ),
            ),
          ),
          btn(Icons.add_rounded, value + step, context.l10n.increase),
        ],
      ),
    );
  }
}
