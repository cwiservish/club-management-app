import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/theme_provider.dart';

// Custom painter to draw a dashed border around the Choose File container
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.2,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(10),
      ));

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + gap);
        canvas.drawPath(segment, paint);
        distance += gap * 2.0;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Import Schedule Page ───────────────────────────────────────────────────

class ImportSchedulePage extends ConsumerStatefulWidget {
  const ImportSchedulePage({super.key});

  @override
  ConsumerState<ImportSchedulePage> createState() => _ImportSchedulePageState();
}

class _ImportSchedulePageState extends ConsumerState<ImportSchedulePage> {
  // Step state: 1 = Source, 2 = Map, 3 = Review, 4 = Success
  int _currentStep = 1;

  // Step 1 states
  String _fileType = 'CSV'; // 'CSV' or 'iCal'
  String? _pickedFileName;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'ics'],
      );
      if (result != null && result.files.single.name.isNotEmpty) {
        setState(() {
          _pickedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  // Step 2 states
  String _mapDate = 'Date';
  String _mapStartTime = 'Start Time';
  String _mapOpponent = 'Visitor';
  String _mapHomeAway = 'Home/Away';
  String _mapLocation = 'Field';
  String _mapNotes = 'Notes';
  String _mapEventType = '— Set a default on the next step';

  final List<String> _mappingOptions = [
    'Date',
    'Start Time',
    'Visitor',
    'Home/Away',
    'Field',
    'Notes',
    '— Set a default on the next step',
    '— Don\'t import',
  ];

  // Step 3 states
  String _defaultEventType = 'Game'; // Game, Practice, Scrimmage

  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final colors = AppColors.current;

    return Scaffold(
      backgroundColor: colors.isDark ? colors.background : const Color(0xFFF4F5F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Back Navigation Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: _buildBackButton(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  // Title & Description
                  Text(
                    'Import schedule',
                    style: AppTextStyles.heading22.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'One-time import — we read your file once and add the events. No syncing or subscriptions; edit anything afterward like a normal event.',
                    style: AppTextStyles.body14.copyWith(
                      color: colors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progress bar (only for Steps 1, 2, 3)
                  if (_currentStep <= 3) ...[
                    _buildProgressBar(_currentStep),
                    const SizedBox(height: 16),
                  ],

                  // Form Container
                  _buildFormCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final colors = AppColors.current;
    return GestureDetector(
      onTap: () => context.pop(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back_ios_new, size: 16, color: colors.primary),
          const SizedBox(width: 4),
          Text(
            'Schedule',
            style: AppTextStyles.body16.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int currentStep) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _buildStepCircle(1, 'Source', currentStep >= 1),
            _buildStepLine(currentStep >= 2),
            _buildStepCircle(2, 'Map', currentStep >= 2),
            _buildStepLine(currentStep >= 3),
            _buildStepCircle(3, 'Review', currentStep >= 3),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(int stepNum, String label, bool isCompleted) {
    final colors = AppColors.current;
    const activeColor = Color(0xFF00E5FF);
    final inactiveColor = colors.isDark ? colors.card : const Color(0xFFE0E0E0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? activeColor : inactiveColor,
          ),
          child: Text(
            stepNum.toString(),
            style: TextStyle(
              color: isCompleted ? Colors.black : colors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.body13.copyWith(
            color: isCompleted ? colors.textPrimary : colors.textSecondary,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isCompleted) {
    const activeColor = Color(0xFF00E5FF);
    return Expanded(
      child: Container(
        height: 1.2,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: isCompleted ? activeColor : AppColors.current.border,
      ),
    );
  }

  Widget _buildFormCard() {
    final colors = AppColors.current;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.isDark ? colors.card : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildFormContent(),
    );
  }

  Widget _buildFormContent() {
    switch (_currentStep) {
      case 1:
        return _buildSourceStep();
      case 2:
        return _buildMapStep();
      case 3:
        return _buildReviewStep();
      case 4:
        return _buildSuccessStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── STEP 1: SOURCE ──
  Widget _buildSourceStep() {
    final colors = AppColors.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Importing banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colors.isDark ? const Color(0xFF0A2E33) : const Color(0xFFE0F7FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: colors.isDark ? const Color(0xFF00E5FF) : const Color(0xFF006064), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Importing games, practices & scrimmages',
                  style: AppTextStyles.body14.copyWith(
                    color: colors.isDark ? const Color(0xFF00E5FF) : const Color(0xFF006064),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // File type selector
        Text(
          'File type',
          style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildFileTypeButton('CSV'),
            const SizedBox(width: 12),
            _buildFileTypeButton('iCal / ICS'),
          ],
        ),
        const SizedBox(height: 24),

        // File picker dotted border
        Text(
          'File',
          style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 8),
        CustomPaint(
          painter: DashedBorderPainter(
            color: colors.border,
            strokeWidth: 1.2,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: _pickFile,
              child: _pickedFileName != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.insert_drive_file_outlined, color: colors.primary, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          _pickedFileName!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body16.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to choose a different file',
                          style: AppTextStyles.body13.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Container(
                      width: 180,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Choose file',
                        style: AppTextStyles.heading16.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Supported: CSV, iCal (.ics). We\'ll guess which column is which — you confirm on the next step.',
          style: AppTextStyles.body13.copyWith(color: colors.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 32),

        // Bottom continue
        GestureDetector(
          onTap: () => setState(() => _currentStep = 2),
          child: Container(
            height: 48,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Continue',
              style: AppTextStyles.heading16.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileTypeButton(String type) {
    final colors = AppColors.current;
    final isSelected = (type == 'CSV' && _fileType == 'CSV') || (type != 'CSV' && _fileType == 'iCal');
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _fileType = type == 'CSV' ? 'CSV' : 'iCal'),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (colors.isDark ? colors.primary : const Color(0xFF2F54EB))
                : (colors.isDark ? colors.background : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? (colors.isDark ? colors.primary : const Color(0xFF2F54EB))
                  : colors.border,
              width: 1.2,
            ),
          ),
          child: Text(
            type,
            style: AppTextStyles.body14.copyWith(
              color: isSelected
                  ? (colors.isDark ? Colors.black : Colors.white)
                  : colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ── STEP 2: MAP ──
  Widget _buildMapStep() {
    final colors = AppColors.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle
        Text(
          'Match the columns from your file to our event fields. Date and start time are required — the rest are optional.',
          style: AppTextStyles.body13.copyWith(color: colors.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 20),

        // Mapping Form Fields
        _buildMapField('Date', _mapDate, true, (v) => setState(() => _mapDate = v!)),
        const SizedBox(height: 16),
        _buildMapField('Start time', _mapStartTime, true, (v) => setState(() => _mapStartTime = v!)),
        const SizedBox(height: 16),
        _buildMapField('Opponent', _mapOpponent, false, (v) => setState(() => _mapOpponent = v!)),
        const SizedBox(height: 16),
        _buildMapField('Home / Away', _mapHomeAway, false, (v) => setState(() => _mapHomeAway = v!)),
        const SizedBox(height: 16),
        _buildMapField('Location', _mapLocation, false, (v) => setState(() => _mapLocation = v!)),
        const SizedBox(height: 16),
        _buildMapField('Notes', _mapNotes, false, (v) => setState(() => _mapNotes = v!)),
        const SizedBox(height: 16),
        _buildMapField('Event type', _mapEventType, false, (v) => setState(() => _mapEventType = v!)),
        const SizedBox(height: 20),

        // Footer helper
        Text(
          'iCal/ICS files map automatically (start & end times, title, location). Unmapped fields are left blank.',
          style: AppTextStyles.body13.copyWith(color: colors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 32),

        // Navigation Row
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _currentStep = 1),
              child: Text(
                'Back',
                style: AppTextStyles.heading16.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentStep = 3),
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Continue',
                    style: AppTextStyles.heading16.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapField(String label, String value, bool isRequired, ValueChanged<String?> onChanged) {
    final colors = AppColors.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.heading14.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _buildDropdownField<String>(
          value: value,
          items: _mappingOptions,
          itemLabel: (v) => v,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ── STEP 3: REVIEW ──
  Widget _buildReviewStep() {
    final colors = AppColors.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title block inside card
        Text(
          'Review — 8 events ready',
          style: AppTextStyles.heading16.copyWith(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Text(
          'Type for rows without one',
          style: AppTextStyles.heading14.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildReviewTypeButton('Game'),
            const SizedBox(width: 8),
            _buildReviewTypeButton('Practice'),
            const SizedBox(width: 8),
            _buildReviewTypeButton('Scrimmage'),
          ],
        ),
        const SizedBox(height: 20),

        // Card displaying events
        _buildReviewCard(),
        const SizedBox(height: 12),

        // More events
        Text(
          '+ 4 more events',
          style: AppTextStyles.body14.copyWith(color: colors.textSecondary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 32),

        // Bottom buttons
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _currentStep = 2),
              child: Text(
                'Back',
                style: AppTextStyles.heading16.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentStep = 4),
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Import 8 events',
                    style: AppTextStyles.heading16.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewTypeButton(String type) {
    final colors = AppColors.current;
    final isSelected = _defaultEventType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _defaultEventType = type),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (colors.isDark ? colors.primary : const Color(0xFF2F54EB))
                : (colors.isDark ? colors.background : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? (colors.isDark ? colors.primary : const Color(0xFF2F54EB))
                  : colors.border,
              width: 1.2,
            ),
          ),
          child: Text(
            type,
            style: AppTextStyles.body14.copyWith(
              color: isSelected
                  ? (colors.isDark ? Colors.black : Colors.white)
                  : colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard() {
    final colors = AppColors.current;
    return Container(
      decoration: BoxDecoration(
        color: colors.isDark ? colors.background : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _buildReviewRow('JUN 22\nSAT', 'vs Norman Storm 11U', '6:00p · Reaves Park', true),
          Divider(color: colors.border, height: 1),
          _buildReviewRow('JUL 1\nSAT', 'vs Moore Mudcats 11U', '4:30p · Griffin Park', true),
          Divider(color: colors.border, height: 1),
          _buildReviewRow('JUL 8\nSAT', 'vs Edmond Express 11U', '12:00p · Reaves Park', true),
          Divider(color: colors.border, height: 1),
          _buildReviewRow('JUL 15\nSAT', '@ OKC Thunderbolts 11U', '9:00a · Oklahoma City', true),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String date, String title, String subtitle, bool showLabel) {
    final colors = AppColors.current;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Date block
          SizedBox(
            width: 54,
            child: Text(
              date,
              style: AppTextStyles.body13.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          Container(
            width: 1.2,
            height: 36,
            color: colors.border,
            margin: const EdgeInsets.only(right: 12),
          ),
          // Info block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.body13.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          // Game badge
          if (showLabel)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.isDark ? const Color(0xFF0A2E33) : const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Game',
                style: AppTextStyles.body13.copyWith(
                  color: colors.isDark ? const Color(0xFF00E5FF) : const Color(0xFF008CFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── STEP 4: SUCCESS ──
  Widget _buildSuccessStep() {
    final colors = AppColors.current;
    return Column(
      children: [
        const SizedBox(height: 40),
        // Green circular checkmark
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.isDark ? const Color(0xFF0B301B) : const Color(0xFFE8F5E9),
            ),
            child: const Icon(
              Icons.check,
              color: Color(0xFF4CAF50),
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Bold text
        Text(
          '8 events imported',
          style: AppTextStyles.heading20.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Subtext
        Text(
          'Added to your schedule. Edit any of them like a normal event — change the time, location, uniform, or RSVP.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body15.copyWith(
            color: colors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 48),

        // View schedule button
        GestureDetector(
          onTap: () {
            context.go(AppRoutes.schedule);
          },
          child: Container(
            height: 48,
            width: 220,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'View schedule',
              style: AppTextStyles.heading16.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Dropdown Picker Widget ──
  Widget _buildDropdownField<T>({
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    final colors = AppColors.current;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.isDark ? colors.background : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                style: AppTextStyles.body16.copyWith(color: colors.textPrimary),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down, color: colors.textSecondary, size: 20),
          dropdownColor: colors.isDark ? colors.card : Colors.white,
        ),
      ),
    );
  }
}
