import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../models/event_detail_model.dart';

Color? _hexToColor(String hex) {
  if (hex.isEmpty) return null;
  final clean = hex.replaceAll('#', '');
  final value = int.tryParse(clean, radix: 16);
  if (value == null) return null;
  return Color(0xFF000000 | value);
}

class LogisticsSection extends StatelessWidget {
  final EventDetailModel event;

  const LogisticsSection({
    super.key,
    required this.event,
  });

  Future<void> _openGoogleMaps(BuildContext context) async {
    final lat = double.tryParse(event.latitude ?? '');
    final lng = double.tryParse(event.longitude ?? '');

    Uri? uri;
    if (lat != null && lng != null && (lat != 0.0 || lng != 0.0)) {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    } else if (event.locationName.trim().isNotEmpty) {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(event.locationName)}');
    }

    if (uri != null) {
      try {
        final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open map.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening map: $e')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No location details available to show on map.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _openGoogleMaps(context),
            behavior: HitTestBehavior.opaque,
            child: _LogisticsRow(
              icon: Icons.location_on_outlined,
              iconBgColor: colors.primaryLight,
              iconColor: colors.actionAccent,
              label: 'Location',
              value: event.locationName,
              subtitle: event.locationAddress,
              showArrow: true,
              borderBottom: true,
            ),
          ),
          _LogisticsRow(
            icon: Icons.checkroom_outlined,
            label: 'Uniform (Top / Bottom / Socks)',
            value: '',
            valueWidget: _UniformColorDots(
              topHex: event.uniformTopColor,
              bottomHex: event.uniformBottomColor,
              socksHex: event.uniformSocksColor,
            ),
            borderBottom: event.isGame,
          ),
          if (event.isGame) ...[
            _LogisticsRow(
              icon: Icons.swap_horiz,
              label: 'Home / Away / Neutral',
              value: event.homeAway,
              borderBottom: true,
            ),
            _LogisticsRow(
              icon: Icons.star_border,
              label: 'Opponent',
              value: event.opponent.isNotEmpty ? event.opponent : '-',
              borderBottom: true,
            ),
          ],
          _LogisticsRow(
            icon: Icons.access_time,
            label: 'Arrival Time',
            value: event.arrivalTime,
            borderBottom: false,
          ),
        ],
      ),
    );
  }
}

class _LogisticsRow extends StatelessWidget {
  final IconData icon;
  final Color? iconBgColor;
  final Color? iconColor;
  final String label;
  final String value;
  final Widget? valueWidget; // overrides value text when provided
  final String? subtitle;
  final bool showArrow;
  final bool borderBottom;

  const _LogisticsRow({
    required this.icon,
    this.iconBgColor,
    this.iconColor,
    required this.label,
    required this.value,
    this.valueWidget,
    this.subtitle,
    this.showArrow = false,
    this.borderBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    final resolvedIconBg = iconBgColor ?? colors.gray100;
    final resolvedIconColor = iconColor ?? colors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: borderBottom
            ? Border(bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: resolvedIconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: resolvedIconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.label12.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 2),
                if (valueWidget != null)
                  valueWidget!
                else
                  Text(
                    value,
                    style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (showArrow)
            Icon(Icons.chevron_right, size: 20, color: colors.textSecondary),
        ],
      ),
    );
  }
}

// ─── Uniform Color Dots ───────────────────────────────────────────────────────

class _UniformColorDots extends StatelessWidget {
  final String topHex;
  final String bottomHex;
  final String socksHex;

  const _UniformColorDots({
    required this.topHex,
    required this.bottomHex,
    required this.socksHex,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    return Row(
      children: [
        _dot(topHex, colors),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('/', style: AppTextStyles.body14.copyWith(color: colors.textSecondary)),
        ),
        _dot(bottomHex, colors),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('/', style: AppTextStyles.body14.copyWith(color: colors.textSecondary)),
        ),
        _dot(socksHex, colors),
      ],
    );
  }

  Widget _dot(String hex, AppColors colors) {
    final color = _hexToColor(hex);
    final isEmpty = color == null;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isEmpty ? Colors.transparent : color,
        border: Border.all(
          color: isEmpty
              ? colors.textSecondary.withValues(alpha: 0.4)
              : (color == const Color(0xFFFFFFFF)
                  ? Colors.grey.shade400
                  : Colors.transparent),
          width: 1.5,
        ),
      ),
      child: isEmpty
          ? Icon(Icons.block, size: 12, color: colors.textSecondary.withValues(alpha: 0.4))
          : null,
    );
  }
}
