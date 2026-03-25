import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ClosetSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const ClosetSearchBar({super.key, required this.onChanged});

  @override
  State<ClosetSearchBar> createState() => _ClosetSearchBarState();
}

class _ClosetSearchBarState extends State<ClosetSearchBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _hasText = _controller.text.isNotEmpty);
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, color: AppColors.textTertiary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              style: AppTypography.body1(color: AppColors.textPrimary),
              cursorColor: AppColors.accentBlue,
              decoration: InputDecoration(
                hintText: 'Search your wardrobe...',
                hintStyle: AppTypography.body1(color: AppColors.textTertiary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: () => _controller.clear(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.close, color: AppColors.textTertiary, size: 16),
              ),
            )
          else
            const SizedBox(width: 14),
        ],
      ),
    );
  }
}