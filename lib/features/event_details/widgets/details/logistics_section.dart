import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../models/event_detail_model.dart';
import '../../models/uniform_color.dart';

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
          if (event.uniformTopColor.isNotEmpty || event.uniformBottomColor.isNotEmpty || event.uniformSocksColor.isNotEmpty)
            _LogisticsRow(
              icon: Icons.checkroom_outlined,
              label: 'Uniform',
              value: '',
              borderBottom: event.isGame,
              valueWidget: _UniformColorRow(
                topHex: event.uniformTopColor,
                bottomHex: event.uniformBottomColor,
                socksHex: event.uniformSocksColor,
              ),
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
  final String? subtitle;
  final bool showArrow;
  final bool borderBottom;
  final Widget? valueWidget;

  const _LogisticsRow({
    required this.icon,
    this.iconBgColor,
    this.iconColor,
    required this.label,
    required this.value,
    this.subtitle,
    this.showArrow = false,
    this.borderBottom = true,
    this.valueWidget,
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
                valueWidget ?? Text(
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

class _UniformColorRow extends StatelessWidget {
  final String topHex;
  final String bottomHex;
  final String socksHex;

  const _UniformColorRow({
    required this.topHex,
    required this.bottomHex,
    required this.socksHex,
  });

  Widget _colorChip(String hex, BuildContext context) {
    final color = hexToColor(hex);
    final colors = AppColors.current;

    final Widget dot = color == null
        ? SizedBox(
            width: 14,
            height: 14,
            child: CustomPaint(
              painter: _SlashCirclePainter(borderColor: colors.border.withValues(alpha: 0.5)),
            ),
          )
        : Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border.withValues(alpha: 0.5), width: 1),
            ),
          );

    final name = color == null ? 'None' : uniformColorName(hex);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: 4),
        Text(name, style: AppTextStyles.heading15.copyWith(color: colors.textPrimary)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hexes = [topHex, bottomHex, socksHex];
    final chips = hexes.map((h) => _colorChip(h, context)).toList();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < chips.length; i++) ...[
          chips[i],
          if (i < chips.length - 1)
            Text(' / ', style: AppTextStyles.heading15.copyWith(color: AppColors.current.textSecondary)),
        ],
      ],
    );
  }
}

class _SlashCirclePainter extends CustomPainter {
  final Color borderColor;
  const _SlashCirclePainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final slashPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, circlePaint);
    canvas.drawCircle(center, radius, borderPaint);
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.75),
      Offset(size.width * 0.75, size.height * 0.25),
      slashPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

