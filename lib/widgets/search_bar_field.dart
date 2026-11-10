import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ListingSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final String sort;
  final List<String> sortOptions;
  final ValueChanged<String> onSort;

  const ListingSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.sort,
    required this.sortOptions,
    required this.onSort,
  });

  @override
  State<ListingSearchBar> createState() => _ListingSearchBarState();
}

class _ListingSearchBarState extends State<ListingSearchBar> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return Row(children: [
      Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: focused ? AppColors.orange : AppColors.border,
              width: focused ? 1.4 : 1,
            ),
            boxShadow: focused
                ? [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.18),
                blurRadius: 16,
              )
            ]
                : [],
          ),
          child: Row(children: [
            Icon(Icons.search_rounded,
                size: 22, color: focused ? AppColors.orange : AppColors.muted),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                onChanged: widget.onChanged,
                cursorColor: AppColors.orange,
                style: const TextStyle(color: AppColors.text, fontSize: 14.5),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                      color: AppColors.muted.withValues(alpha: 0.7),
                      fontSize: 13.5),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder: (_, v, __) => AnimatedScale(
                scale: v.text.isEmpty ? 0 : 1,
                duration: const Duration(milliseconds: 180),
                child: GestureDetector(
                  onTap: () {
                    widget.controller.clear();
                    widget.onChanged('');
                  },
                  child: const Icon(Icons.close_rounded,
                      size: 20, color: AppColors.muted),
                ),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(width: 10),
      PopupMenuButton<String>(
        tooltip: 'Sort',
        color: AppColors.card,
        onSelected: widget.onSort,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        itemBuilder: (_) => [
          for (final s in widget.sortOptions)
            PopupMenuItem<String>(
              value: s,
              child: Row(children: [
                Icon(
                  s == widget.sort
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: s == widget.sort ? AppColors.orange : AppColors.muted,
                ),
                const SizedBox(width: 10),
                Text(s,
                    style: TextStyle(
                      color: s == widget.sort
                          ? AppColors.orange
                          : AppColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    )),
              ]),
            ),
        ],
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.swap_vert_rounded,
              color: AppColors.orange, size: 22),
        ),
      ),
    ]);
  }
}