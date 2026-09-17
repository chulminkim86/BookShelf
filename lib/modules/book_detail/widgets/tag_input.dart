import 'package:flutter/material.dart';
import '../../../app_theme.dart';

/// 자유롭게 여러 개 입력하는 태그. 장르(고정 목록, 단일 선택)와는 성격이 다르다.
class TagInput extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  const TagInput({super.key, required this.tags, required this.onChanged});

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.tags.contains(text)) {
      _controller.clear();
      return;
    }
    widget.onChanged([...widget.tags, text]);
    _controller.clear();
  }

  void _removeTag(String tag) {
    widget.onChanged(widget.tags.where((t) => t != tag).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.tags.isNotEmpty)
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: widget.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.only(
                  left: AppSpacing.sm,
                  right: 4,
                  top: 4,
                  bottom: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '#$tag',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    InkWell(
                      onTap: () => _removeTag(tag),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.close,
                          size: 15,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        if (widget.tags.isNotEmpty) const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: AppSizes.smallControlHeight,
          child: TextField(
          controller: _controller,
          onSubmitted: (_) => _addTag(),
          textInputAction: TextInputAction.done,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: '태그 입력 후 완료',
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
            isDense: true,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(Icons.add, color: AppColors.primary, size: 18),
              onPressed: _addTag,
            ),
          ),
          ),
        ),
      ],
    );
  }
}
