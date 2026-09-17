import 'package:flutter/material.dart';
import '../../../app_theme.dart';

/// 보관장소 선택 필드. 탭하면 목록이 뜨고, 목록에 없는 장소는 "+"로 추가할 수 있다.
class LocationPicker extends StatelessWidget {
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final ValueChanged<List<String>> onOptionsChanged;

  const LocationPicker({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.onOptionsChanged,
  });

  Future<void> _openPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (sheetContext) {
        return _LocationSheet(
          value: value,
          options: options,
          onChanged: onChanged,
          onOptionsChanged: onOptionsChanged,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openPicker(context),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        height: AppSizes.smallControlHeight,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value ?? '선택',
                  style: TextStyle(
                    fontSize: 13,
                    color: value == null ? AppColors.muted : AppColors.ink,
                    fontWeight: value == null ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationSheet extends StatefulWidget {
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final ValueChanged<List<String>> onOptionsChanged;

  const _LocationSheet({
    required this.value,
    required this.options,
    required this.onChanged,
    required this.onOptionsChanged,
  });

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  late List<String> _options = List.of(widget.options);
  bool _isAdding = false;
  final _newLocationController = TextEditingController();

  @override
  void dispose() {
    _newLocationController.dispose();
    super.dispose();
  }

  void _select(String location) {
    widget.onChanged(location);
    Navigator.of(context).pop();
  }

  void _confirmAdd() {
    final name = _newLocationController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      if (!_options.contains(name)) {
        _options = [..._options, name];
        widget.onOptionsChanged(_options);
      }
      _isAdding = false;
      _newLocationController.clear();
    });
    _select(name);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '보관장소',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._options.map((location) {
              final selected = location == widget.value;
              return InkWell(
                onTap: () => _select(location),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 20,
                        color: selected ? AppColors.primary : AppColors.muted,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.ink,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.xs),
            const Divider(color: AppColors.hairline, height: 1),
            const SizedBox(height: AppSpacing.md),
            if (_isAdding)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newLocationController,
                      autofocus: true,
                      onSubmitted: (_) => _confirmAdd(),
                      decoration: InputDecoration(
                        hintText: '새 장소 이름',
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: _confirmAdd,
                    icon: const Icon(Icons.check, color: AppColors.primary),
                  ),
                ],
              )
            else
              InkWell(
                onTap: () => setState(() => _isAdding = true),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 20, color: AppColors.primary),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        '새 장소 추가',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
