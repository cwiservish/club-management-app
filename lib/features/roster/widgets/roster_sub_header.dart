import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/shared_widgets/custom_svg_icon.dart';
import '../providers/roster_provider.dart';

class RosterSubHeader extends ConsumerStatefulWidget {
  const RosterSubHeader({super.key});

  @override
  ConsumerState<RosterSubHeader> createState() => _RosterSubHeaderState();
}

class _RosterSubHeaderState extends ConsumerState<RosterSubHeader> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final colors = AppColors.current;

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _isSearching
          ? Row(
              children: [
                Icon(Icons.search, color: colors.textSecondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: AppTextStyles.body16.copyWith(color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search players, position, jersey...',
                      hintStyle: AppTextStyles.body16.copyWith(color: colors.gray400),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      ref.read(rosterProvider.notifier).setSearch(val.trim());
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colors.textSecondary, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(rosterProvider.notifier).setSearch('');
                    setState(() {
                      _isSearching = false;
                    });
                  },
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Text(
                    'Roster',
                    style: AppTextStyles.heading18.copyWith(
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CustomSvgIcon(
                      assetPath: AppAssets.searchIcon,
                      size: 20,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
