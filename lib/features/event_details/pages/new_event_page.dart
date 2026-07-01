import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../services/event_detail_service.dart';

// ─── Enums & Models ──────────────────────────────────────────────────────────

enum EventCategory { singleSession, tournament, league }

class UniformColor {
  final String name;
  final Color color;
  final bool isNone;

  const UniformColor({
    required this.name,
    required this.color,
    this.isNone = false,
  });
}

class UniformTemplate {
  final String name;
  final int topIndex;
  final int bottomIndex;
  final int socksIndex;

  const UniformTemplate({
    required this.name,
    required this.topIndex,
    required this.bottomIndex,
    required this.socksIndex,
  });
}

// Custom painter to draw the diagonal red slash for "None" colors
class SlashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.75),
      Offset(size.width * 0.75, size.height * 0.25),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── New Event Page ──────────────────────────────────────────────────────────

class NewEventPage extends ConsumerStatefulWidget {
  const NewEventPage({super.key});

  @override
  ConsumerState<NewEventPage> createState() => _NewEventPageState();
}

class _NewEventPageState extends ConsumerState<NewEventPage> {
  // Category state
  EventCategory _category = EventCategory.singleSession;

  // Single Session specific state
  String _selectedEventType = 'Practice';
  final List<String> _eventTypes = ['Game', 'Practice', 'Scrimmage', 'Team event', 'Camp'];

  final _titleController = TextEditingController();
  final _locationController = TextEditingController(text: 'Gillis-Rother Soccer Complex');
  final _notesController = TextEditingController();

  // Location state
  String _locationName = '';
  String _latitude = '';
  String _longitude = '';
  List<dynamic> _locationSuggestions = [];
  bool _isLoadingLocation = false;
  OverlayEntry? _locationOverlay;
  Timer? _locationDebounceTimer;
  final GlobalKey _locationFieldKey = GlobalKey();

  // Save template states
  bool _showSaveTemplateForm = false;
  final _templateNameController = TextEditingController();

  // Saved Uniform templates
  final List<UniformTemplate> _savedTemplates = [
    const UniformTemplate(name: 'vishal', topIndex: 10, bottomIndex: 1, socksIndex: 10),
  ];
  String _selectedUniformMode = 'vishal';

  // Opponent Add inline state
  bool _showAddOpponentInline = false;
  bool _saveOpponentForFuture = true;
  final _newOpponentNameController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 0); // 12:00 PM
  int _durationHours = 1;
  int _durationMinutes = 30;
  // Custom Time Picker overlay
  final GlobalKey _startTimeFieldKey = GlobalKey();
  OverlayEntry? _timePickerOverlay;
  // Game & Scrimmage specific fields
  String _selectedOpponent = 'Select opponent...';
  final List<String> _opponents = [
    'Select opponent...',
    'Match Fit Academy 09 (1-1-1 all-time)',
    'Team Orange Boca 09 (1-0-0 all-time)',
    'Bryn Mawr SC 09 (first meeting)',
    'PDA White (1-0-1 all-time)',
    '+ Add a new opponent...',
  ];
  String _homeOrAway = 'Home'; // 'Home', 'Away', 'Neutral'
  String _arriveEarly = 'No set arrival time';
  final List<String> _arriveEarlyOptions = [
    'No set arrival time',
    '15 min early',
    '30 min early',
    '45 min early',
    '1 hr early',
    '1 hr 15 min early',
    '1 hr 30 min early',
  ];

  // Tournament/League specific state
  bool _knowsSchedule = false; // false = Not yet — placeholder, true = Yes, I have it
  DateTime? _startDate;
  DateTime? _endDate;

  // Uniform Pickers State (Selected color index)
  int _topColorIndex = 0;
  int _bottomColorIndex = 0;
  int _socksColorIndex = 0;

  // Uniform color palette matching the 4x7 grid in design
  final List<UniformColor> _uniformColors = const [
    // Row 1
    UniformColor(name: 'No color set', color: Colors.transparent, isNone: true),
    UniformColor(name: 'White', color: Color(0xFFFFFFFF)),
    UniformColor(name: 'Cream', color: Color(0xFFF5EFEB)),
    UniformColor(name: 'Light Gray', color: Color(0xFFCFD8DC)),
    UniformColor(name: 'Slate Gray', color: Color(0xFF90A4AE)),
    UniformColor(name: 'Dark Gray', color: Color(0xFF37474F)),
    UniformColor(name: 'Black', color: Color(0xFF212121)),
    // Row 2
    UniformColor(name: 'Sky Blue', color: Color(0xFF90CAF9)),
    UniformColor(name: 'Blue', color: Color(0xFF1E88E5)),
    UniformColor(name: 'Navy Blue', color: Color(0xFF1A237E)),
    UniformColor(name: 'Teal', color: Color(0xFF00796B)),
    UniformColor(name: 'Red', color: Color(0xFFE53935)),
    UniformColor(name: 'Crimson', color: Color(0xFFC62828)),
    UniformColor(name: 'Wine', color: Color(0xFF8D0B3C)),
    // Row 3
    UniformColor(name: 'Maroon', color: Color(0xFF4A148C)),
    UniformColor(name: 'Pink', color: Color(0xFFF48FB1)),
    UniformColor(name: 'Magenta', color: Color(0xFFD81B60)),
    UniformColor(name: 'Purple', color: Color(0xFF512DA8)),
    UniformColor(name: 'Lime', color: Color(0xFF7CB342)),
    UniformColor(name: 'Green', color: Color(0xFF2E7D32)),
    UniformColor(name: 'Dark Green', color: Color(0xFF1B5E20)),
    // Row 4
    UniformColor(name: 'Yellow', color: Color(0xFFFFEB3B)),
    UniformColor(name: 'Gold', color: Color(0xFFFFC107)),
    UniformColor(name: 'Olive', color: Color(0xFF8D8D1A)),
    UniformColor(name: 'Orange', color: Color(0xFFF57C00)),
    UniformColor(name: 'Rust', color: Color(0xFFD84315)),
    UniformColor(name: 'Chocolate', color: Color(0xFF4E342E)),
    UniformColor(name: 'Tan', color: Color(0xFFD7CCC8)),
  ];

  // ─── Location Overlay ────────────────────────────────────────────────────────

  void _showLocationOverlay() {
    final renderBox = _locationFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    if (_locationOverlay != null) {
      _locationOverlay!.markNeedsBuild();
      return;
    }

    _locationOverlay = OverlayEntry(
      builder: (_) {
        final colors = AppColors.current;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideLocationOverlay,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 4,
              width: size.width,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: colors.isDark ? colors.card : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isLoadingLocation
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _locationSuggestions.length,
                            itemBuilder: (ctx, i) {
                              final item = _locationSuggestions[i] as Map;
                              final name = item['structured_formatting']?['main_text'] ?? item['description'] ?? '';
                              final subtitle = item['structured_formatting']?['secondary_text'] ?? '';
                              return InkWell(
                                onTap: () => _selectLocation(item),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: colors.border.withValues(alpha: 0.3)),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on_outlined, color: colors.primary, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              name,
                                              style: AppTextStyles.body15.copyWith(
                                                color: colors.textPrimary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if ((subtitle as String).isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                subtitle,
                                                style: AppTextStyles.body13.copyWith(color: colors.textSecondary),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_locationOverlay!);
  }

  void _hideLocationOverlay() {
    _locationOverlay?.remove();
    _locationOverlay = null;
  }

  void _onLocationChanged(String val) {
    _locationDebounceTimer?.cancel();
    if (val.trim().isEmpty) {
      _hideLocationOverlay();
      setState(() {
        _locationSuggestions = [];
        _locationName = '';
        _latitude = '';
        _longitude = '';
      });
      return;
    }
    _locationDebounceTimer = Timer(const Duration(milliseconds: 400), () async {
      final service = ref.read(eventDetailServiceProvider);
      setState(() => _isLoadingLocation = true);
      _showLocationOverlay();
      try {
        final results = await service.fetchPlacesAutocomplete(val);
        if (!mounted) return;
        setState(() {
          _locationSuggestions = results;
          _isLoadingLocation = false;
        });
        _locationOverlay?.markNeedsBuild();
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _locationSuggestions = [];
          _isLoadingLocation = false;
        });
        _hideLocationOverlay();
      }
    });
  }

  Future<void> _selectLocation(Map item) async {
    final service = ref.read(eventDetailServiceProvider);
    if (item.containsKey('latitude')) {
      setState(() {
        _locationName = item['name']?.toString() ?? '';
        _latitude = item['latitude']?.toString() ?? '';
        _longitude = item['longitude']?.toString() ?? '';
        _locationController.text = _locationName;
      });
      _hideLocationOverlay();
    } else {
      final placeId = item['place_id']?.toString() ?? '';
      final name = item['structured_formatting']?['main_text'] ?? item['description'] ?? '';
      if (placeId.isNotEmpty) {
        setState(() => _isLoadingLocation = true);
        _locationOverlay?.markNeedsBuild();
        final details = await service.fetchPlaceDetails(placeId);
        if (!mounted) return;
        setState(() {
          _locationName = name;
          _latitude = details?['geometry']?['location']?['lat']?.toString() ?? '';
          _longitude = details?['geometry']?['location']?['lng']?.toString() ?? '';
          _locationController.text = name;
          _isLoadingLocation = false;
        });
        _hideLocationOverlay();
      }
    }
  }

  @override
  void _showStartTimeOverlay() {
    _removeTimePickerOverlay();

    final renderBox = _startTimeFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _timePickerOverlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeTimePickerOverlay,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 4,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {},
                child: _buildCustomTimePickerCard(
                  onTimeChanged: () {
                    setState(() {});
                    _timePickerOverlay?.markNeedsBuild();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_timePickerOverlay!);
  }

  void _removeTimePickerOverlay() {
    _timePickerOverlay?.remove();
    _timePickerOverlay = null;
  }

  @override
  void dispose() {
    _removeTimePickerOverlay();
    _hideLocationOverlay();
    _locationDebounceTimer?.cancel();
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _templateNameController.dispose();
    _newOpponentNameController.dispose();
    super.dispose();
  }

  // Dynamic End Time computation based on Start Time + Duration
  String _getEndTimeString() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final durationMinutes = _durationHours * 60 + _durationMinutes;
    final totalMinutes = startMinutes + durationMinutes;

    final endHour = (totalMinutes ~/ 60) % 24;
    final endMinute = totalMinutes % 60;

    final amPm = endHour >= 12 ? 'pm' : 'am';
    final displayHour = endHour == 0 ? 12 : (endHour > 12 ? endHour - 12 : endHour);
    final displayMinuteStr = endMinute.toString().padLeft(2, '0');

    return 'Ends at $displayHour:$displayMinuteStr $amPm';
  }

  // Pickers
  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }


  void _onSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Event created successfully (mocked)'),
        backgroundColor: AppColors.current.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final colors = AppColors.current;

    return Scaffold(
      backgroundColor: colors.isDark ? colors.background : const Color(0xFFF4F5F7),
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              title: 'New Event',
              leftIcon: Icons.close,
              leftLabel: 'Close',
              onLeftTap: () => context.pop(),
              rightText: 'Save',
              onRightTap: _onSave,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      'New Event',
                      style: AppTextStyles.heading22.copyWith(color: colors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFormContainer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContainer() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category Header ──
          Text(
            'What are you adding?',
            style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCategoryButton(EventCategory.singleSession, 'Single session'),
              const SizedBox(width: 8),
              _buildCategoryButton(EventCategory.tournament, 'Tournament'),
              const SizedBox(width: 8),
              _buildCategoryButton(EventCategory.league, 'League'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getCategorySubtext(),
            style: AppTextStyles.body14.copyWith(
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // ── Category Specific Form Body ──
          if (_category == EventCategory.singleSession) ...[
            _buildSingleSessionForm()
          ] else if (_category == EventCategory.tournament) ...[
            _buildTournamentForm()
          ] else if (_category == EventCategory.league) ...[
            _buildLeagueForm()
          ]
        ],
      ),
    );
  }

  String _getCategorySubtext() {
    switch (_category) {
      case EventCategory.singleSession:
        return 'A single game, practice, or team event with a known date and time. Add one for each session if you have several in a day.';
      case EventCategory.tournament:
        return 'A multi-day tournament. You usually know the date range months ahead but not each game time until closer — add it as a placeholder now and fill in games later.';
      case EventCategory.league:
        return 'A league season spanning several weeks. Add the date range now; fill in individual game dates and times as the league publishes them.';
    }
  }

  Widget _buildCategoryButton(EventCategory category, String label) {
    final colors = AppColors.current;
    final isSelected = _category == category;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _category = category),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (colors.isDark ? colors.primary : const Color(0xFF2F54EB))
                : (colors.isDark ? colors.background : Colors.white),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? (colors.isDark ? colors.primary : const Color(0xFF2F54EB))
                  : colors.border,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
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

  Widget _buildBottomButton() {
    final colors = AppColors.current;
    String buttonText = 'Save';
    if (_category == EventCategory.singleSession) {
      buttonText = 'Save event';
    } else {
      buttonText = _knowsSchedule ? 'Save event' : 'Save placeholder';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _onSave,
          child: Container(
            height: 48,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              buttonText,
              style: AppTextStyles.heading16.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.body16.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Single Session Form ──
  Widget _buildSingleSessionForm() {
    final colors = AppColors.current;
    final dateStr = _selectedDate == null
        ? 'dd-mm-yyyy'
        : '${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}';
    final startHour = _startTime.hour == 0 ? 12 : (_startTime.hour > 12 ? _startTime.hour - 12 : _startTime.hour);
    final startMinuteStr = _startTime.minute.toString().padLeft(2, '0');
    final startAmPm = _startTime.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$startHour:$startMinuteStr $startAmPm';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Type
        Text(
          'Event type',
          style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _eventTypes.map((type) => _buildEventTypeChip(type)).toList(),
        ),
        // Import Link
        // GestureDetector(
        //   onTap: () => context.push(AppRoutes.importSchedule),
        //   child: Row(
        //     children: [
        //       Icon(Icons.file_download_outlined, color: colors.primary, size: 20),
        //       const SizedBox(width: 6),
        //       Expanded(
        //         child: Text(
        //           'Have a full schedule? Import a calendar (CSV / iCal)',
        //           style: AppTextStyles.body14.copyWith(
        //             color: colors.primary,
        //             fontWeight: FontWeight.w600,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        const SizedBox(height: 20),

        // Title or Opponent Field
        if (_selectedEventType == 'Game' || _selectedEventType == 'Scrimmage') ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Opponent',
                style: AppTextStyles.heading14.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: 8),
              _buildDropdownField<String>(
                value: _selectedOpponent,
                items: _opponents,
                itemLabel: (v) => v,
                onChanged: (val) {
                  if (val == '+ Add a new opponent...') {
                    setState(() {
                      _showAddOpponentInline = true;
                      _selectedOpponent = '+ Add a new opponent...';
                    });
                  } else if (val != null) {
                    setState(() {
                      _selectedOpponent = val;
                      _showAddOpponentInline = false;
                    });
                  }
                },
              ),
              if (_showAddOpponentInline) ...[
                const SizedBox(height: 12),
                _buildAddOpponentInlineCard(),
              ],
            ],
          ),
        ] else ...[
          _buildTextField(
            label: 'Title',
            hintText: 'e.g. Practice',
            controller: _titleController,
          ),
        ],
        const SizedBox(height: 20),

        // Date Field
        _buildPickerField(
          label: 'Date',
          valueText: dateStr,
          isPlaceholder: _selectedDate == null,
          icon: Icons.calendar_today_outlined,
          onTap: () => _pickDate(context),
        ),
        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: KeyedSubtree(
                key: _startTimeFieldKey,
                child: _buildPickerField(
                  label: 'Start time',
                  valueText: timeStr,
                  isPlaceholder: false,
                  icon: Icons.access_time,
                  onTap: _showStartTimeOverlay,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration',
                    style: AppTextStyles.heading14.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField<int>(
                          value: _durationHours,
                          items: const [0, 1, 2, 3, 4, 5, 6, 7, 8],
                          itemLabel: (v) => v == 1 ? '1 hr' : '$v hrs',
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _durationHours = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildDropdownField<int>(
                          value: _durationMinutes,
                          items: const [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55],
                          itemLabel: (v) => '$v min',
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _durationMinutes = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.access_time_filled_outlined, color: colors.textSecondary, size: 14),
            const SizedBox(width: 4),
            Text(
              _getEndTimeString(),
              style: AppTextStyles.body13.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
        if (_selectedEventType == 'Game' || _selectedEventType == 'Scrimmage') ...[
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Home or away',
                style: AppTextStyles.heading14.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildHomeOrAwayButton('Home'),
                  const SizedBox(width: 12),
                  _buildHomeOrAwayButton('Away'),
                  const SizedBox(width: 12),
                  _buildHomeOrAwayButton('Neutral'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Arrive how early',
                style: AppTextStyles.heading14.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: 8),
              _buildDropdownField<String>(
                value: _arriveEarly,
                items: _arriveEarlyOptions,
                itemLabel: (v) => v,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _arriveEarly = val);
                  }
                },
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),

        // Location Field
        _buildTextField(
          fieldKey: _locationFieldKey,
          label: 'Location',
          hintText: 'Search location...',
          controller: _locationController,
          prefixIcon: Icon(Icons.location_on_outlined, color: colors.textSecondary),
          suffixIcon: _locationController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _locationController.clear();
                      _locationName = '';
                      _latitude = '';
                      _longitude = '';
                    });
                    _hideLocationOverlay();
                  },
                  child: Icon(Icons.close, color: colors.textSecondary),
                )
              : null,
          onChanged: _onLocationChanged,
        ),
        const SizedBox(height: 24),

        // Uniform Section
        Divider(color: colors.border, height: 1),
        const SizedBox(height: 20),
        _buildUniformSectionHeader(),
        const SizedBox(height: 8),
        _buildUniformFormContent(),
        const SizedBox(height: 20),

        // Notes for families
        _buildTextField(
          label: 'Notes for families',
          hintText: 'Arrive 30 min early. Bring both jerseys.',
          controller: _notesController,
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        _buildBottomButton(),
      ],
    );
  }

  // ── Tournament Form ──
  Widget _buildTournamentForm() {
    return _buildSharedMultiDayForm(
      titlePlaceholder: 'e.g. Spring Showcase Tournament',
    );
  }

  // ── League Form ──
  Widget _buildLeagueForm() {
    return _buildSharedMultiDayForm(
      titlePlaceholder: 'e.g. Fall ECNL RL League',
    );
  }

  // Tournament and League share a very similar structure
  Widget _buildSharedMultiDayForm({required String titlePlaceholder}) {
    final colors = AppColors.current;
    final dateStr = _selectedDate == null
        ? 'dd-mm-yyyy'
        : '${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}';
    final startHour = _startTime.hour == 0 ? 12 : (_startTime.hour > 12 ? _startTime.hour - 12 : _startTime.hour);
    final startMinuteStr = _startTime.minute.toString().padLeft(2, '0');
    final startAmPm = _startTime.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$startHour:$startMinuteStr $startAmPm';

    final startStr = _startDate == null
        ? 'dd-mm-yyyy'
        : '${_startDate!.day.toString().padLeft(2, '0')}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.year}';
    final endStr = _endDate == null
        ? 'dd-mm-yyyy'
        : '${_endDate!.day.toString().padLeft(2, '0')}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        _buildTextField(
          label: 'Title',
          hintText: titlePlaceholder,
          controller: _titleController,
        ),
        const SizedBox(height: 20),

        // Do you know the game schedule?
        Text(
          'Do you know the game schedule?',
          style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildScheduleOptionButton(false, 'Not yet — placeholder'),
            const SizedBox(width: 12),
            _buildScheduleOptionButton(true, 'Yes, I have it'),
          ],
        ),
        const SizedBox(height: 16),

        if (!_knowsSchedule) ...[
          // Subtext for placeholder
          Text(
            'Add the date range now as a placeholder. You can edit it later to fill in each game\'s date and time once you know them — hotels and details you attach now will stay connected.',
            style: AppTextStyles.body13.copyWith(color: colors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 20),

          // Start Date & End Date Pickers
          Row(
            children: [
              Expanded(
                child: _buildPickerField(
                  label: 'Start date',
                  valueText: startStr,
                  isPlaceholder: _startDate == null,
                  icon: Icons.calendar_today_outlined,
                  onTap: () => _pickStartDate(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPickerField(
                  label: 'End date',
                  valueText: endStr,
                  isPlaceholder: _endDate == null,
                  icon: Icons.calendar_today_outlined,
                  onTap: () => _pickEndDate(context),
                ),
              ),
            ],
          ),
        ] else ...[
          // Date Field
          _buildPickerField(
            label: 'Date',
            valueText: dateStr,
            isPlaceholder: _selectedDate == null,
            icon: Icons.calendar_today_outlined,
            onTap: () => _pickDate(context),
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: KeyedSubtree(
                  key: _startTimeFieldKey,
                  child: _buildPickerField(
                    label: 'Start time',
                    valueText: timeStr,
                    isPlaceholder: false,
                    icon: Icons.access_time,
                    onTap: _showStartTimeOverlay,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Duration',
                      style: AppTextStyles.heading14.copyWith(color: colors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField<int>(
                            value: _durationHours,
                            items: const [0, 1, 2, 3, 4, 5, 6, 7, 8],
                            itemLabel: (v) => v == 1 ? '1 hr' : '$v hrs',
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _durationHours = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildDropdownField<int>(
                            value: _durationMinutes,
                            items: const [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55],
                            itemLabel: (v) => '$v min',
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _durationMinutes = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time_filled_outlined, color: colors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Text(
                _getEndTimeString(),
                style: AppTextStyles.body13.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Home or Away Selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Home or away',
                style: AppTextStyles.heading14.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildHomeOrAwayButton('Home'),
                  const SizedBox(width: 12),
                  _buildHomeOrAwayButton('Away'),
                  const SizedBox(width: 12),
                  _buildHomeOrAwayButton('Neutral'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Arrive how early
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Arrive how early',
                style: AppTextStyles.heading14.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: 8),
              _buildDropdownField<String>(
                value: _arriveEarly,
                items: _arriveEarlyOptions,
                itemLabel: (v) => v,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _arriveEarly = val);
                  }
                },
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),

        // Location Field
        _buildTextField(
          fieldKey: _locationFieldKey,
          label: 'Location',
          hintText: 'Search location...',
          controller: _locationController,
          prefixIcon: Icon(Icons.location_on_outlined, color: colors.textSecondary),
          suffixIcon: _locationController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _locationController.clear();
                      _locationName = '';
                      _latitude = '';
                      _longitude = '';
                    });
                    _hideLocationOverlay();
                  },
                  child: Icon(Icons.close, color: colors.textSecondary),
                )
              : null,
          onChanged: _onLocationChanged,
        ),
        const SizedBox(height: 20),

        // Uniform Section
        if (_knowsSchedule) ...[
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 20),
          _buildUniformSectionHeader(),
          const SizedBox(height: 8),
          _buildUniformFormContent(),
          const SizedBox(height: 20),
        ],

        // Notes for families
        _buildTextField(
          label: 'Notes for families',
          hintText: 'Arrive 30 min early. Bring both jerseys.',
          controller: _notesController,
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        _buildBottomButton(),
      ],
    );
  }

  // ── Helper Widgets ──

  Color _getEventTypeBgColor(String type, bool isSelected) {
    if (!isSelected) return Colors.transparent;
    switch (type) {
      case 'Game':
        return const Color(0xFFFFC107);
      case 'Practice':
        return const Color(0xFF00E5FF);
      case 'Scrimmage':
        return const Color(0xFF2F54EB);
      case 'Team event':
        return const Color(0xFFE91E63);
      case 'Camp':
        return const Color(0xFF00C853);
      default:
        return const Color(0xFF00E5FF);
    }
  }

  Color _getEventTypeTextColor(String type, bool isSelected) {
    final colors = AppColors.current;
    if (!isSelected) return colors.textSecondary;
    switch (type) {
      case 'Game':
      case 'Practice':
        return Colors.black;
      case 'Scrimmage':
      case 'Team event':
      case 'Camp':
        return Colors.white;
      default:
        return Colors.black;
    }
  }

  Widget _buildHomeOrAwayButton(String option) {
    final colors = AppColors.current;
    final isSelected = _homeOrAway == option;
    return GestureDetector(
      onTap: () => setState(() => _homeOrAway = option),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 15),
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
          option,
          style: AppTextStyles.body14.copyWith(
            color: isSelected
                ? (colors.isDark ? Colors.black : Colors.white)
                : colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEventTypeChip(String type) {
    final colors = AppColors.current;
    final isSelected = _selectedEventType == type;

    final selectedColor = _getEventTypeBgColor(type, isSelected);
    final textColor = _getEventTypeTextColor(type, isSelected);
    final borderColor = isSelected ? selectedColor : colors.border;

    return GestureDetector(
      onTap: () => setState(() => _selectedEventType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selectedColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
        ),
        child: Text(
          type,
          style: AppTextStyles.body14.copyWith(
            color: textColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleOptionButton(bool activeValue, String label) {
    final colors = AppColors.current;
    final isSelected = _knowsSchedule == activeValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _knowsSchedule = activeValue),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
            label,
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

  Widget _buildTextField({
    Key? fieldKey,
    required String label,
    required String hintText,
    required TextEditingController controller,
    Widget? prefixIcon,
    Widget? suffixIcon,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    final colors = AppColors.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.heading14.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextField(
          key: fieldKey,
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          style: AppTextStyles.body16.copyWith(color: colors.textPrimary),
          cursorColor: colors.primary,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.body16.copyWith(color: colors.textSecondary.withValues(alpha: 0.5)),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: colors.isDark ? colors.background : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerField({
    required String label,
    required String valueText,
    required bool isPlaceholder,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = AppColors.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.heading14.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colors.isDark ? colors.background : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    valueText,
                    style: AppTextStyles.body16.copyWith(
                      color: isPlaceholder
                          ? colors.textSecondary.withValues(alpha: 0.5)
                          : colors.textPrimary,
                    ),
                  ),
                ),
                Icon(icon, color: colors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

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

  Widget _buildUniformColorSelector({
    required String label,
    required int selectedIndex,
    required ValueChanged<int> onColorSelected,
  }) {
    final colors = AppColors.current;
    final selectedColorName = _uniformColors[selectedIndex].name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label — $selectedColorName',
          style: AppTextStyles.heading14.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_uniformColors.length, (index) {
            final item = _uniformColors[index];
            final isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () => onColorSelected(index),
              child: Container(
                width: 38,
                height: 38,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? (colors.isDark ? colors.primary : const Color(0xFF2F54EB))
                        : Colors.transparent,
                    width: 2.0,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.isNone ? Colors.white : item.color,
                    border: item.color == const Color(0xFFFFFFFF)
                        ? Border.all(color: Colors.grey.shade300, width: 1.0)
                        : null,
                  ),
                  child: item.isNone
                      ? CustomPaint(painter: SlashPainter())
                      : null,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildUniformSectionHeader() {
    final colors = AppColors.current;
    
    final topColor = _uniformColors[_topColorIndex].color;
    final bottomColor = _uniformColors[_bottomColorIndex].color;
    final socksColor = _uniformColors[_socksColorIndex].color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Uniform',
          style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
        ),
        Container(
          width: 24,
          height: 18,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniPreviewCapsule(topColor),
              _buildMiniPreviewCapsule(bottomColor),
              _buildMiniPreviewCapsule(socksColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniPreviewCapsule(Color color) {
    return Container(
      width: 24,
      height: 4,
      decoration: BoxDecoration(
        color: color == Colors.transparent ? Colors.grey.shade300 : color,
        borderRadius: BorderRadius.circular(1.5),
        border: color == Colors.white
            ? Border.all(color: Colors.grey.shade400, width: 0.5)
            : null,
      ),
    );
  }

  Widget _buildUniformFormContent() {
    final colors = AppColors.current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ..._savedTemplates.map((template) {
              final isSelected = _selectedUniformMode == template.name;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedUniformMode = template.name;
                    _topColorIndex = template.topIndex;
                    _bottomColorIndex = template.bottomIndex;
                    _socksColorIndex = template.socksIndex;
                  });
                },
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  margin: const EdgeInsets.only(right: 12),
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
                    template.name,
                    style: AppTextStyles.body14.copyWith(
                      color: isSelected
                          ? (colors.isDark ? Colors.black : Colors.white)
                          : colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedUniformMode = 'New combo';
                });
              },
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedUniformMode == 'New combo'
                      ? (colors.isDark ? colors.primary : const Color(0xFF2F54EB))
                      : (colors.isDark ? colors.background : Colors.white),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedUniformMode == 'New combo'
                        ? (colors.isDark ? colors.primary : const Color(0xFF2F54EB))
                        : colors.border,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  'New combo',
                  style: AppTextStyles.body14.copyWith(
                    color: _selectedUniformMode == 'New combo'
                        ? (colors.isDark ? Colors.black : Colors.white)
                        : colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        if (_selectedUniformMode == 'New combo') ...[
          const SizedBox(height: 20),
          Text(
            'Tip: save combos as named templates — like "Home Whites" — and next time setting the uniform is one tap.',
            style: AppTextStyles.body13.copyWith(color: colors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),

          _buildUniformColorSelector(
            label: 'TOP',
            selectedIndex: _topColorIndex,
            onColorSelected: (idx) => setState(() => _topColorIndex = idx),
          ),
          const SizedBox(height: 20),
          _buildUniformColorSelector(
            label: 'BOTTOM',
            selectedIndex: _bottomColorIndex,
            onColorSelected: (idx) => setState(() => _bottomColorIndex = idx),
          ),
          const SizedBox(height: 20),
          _buildUniformColorSelector(
            label: 'SOCKS',
            selectedIndex: _socksColorIndex,
            onColorSelected: (idx) => setState(() => _socksColorIndex = idx),
          ),
          const SizedBox(height: 16),

          if (!_showSaveTemplateForm) ...[
            TextButton(
              onPressed: () => setState(() => _showSaveTemplateForm = true),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                'Save this combo as a template',
                style: AppTextStyles.body14.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            TextField(
              controller: _templateNameController,
              style: AppTextStyles.body16.copyWith(color: colors.textPrimary),
              cursorColor: colors.primary,
              decoration: InputDecoration(
                hintText: 'Template name — e.g. "Home Whites"',
                hintStyle: AppTextStyles.body16.copyWith(color: colors.textSecondary.withValues(alpha: 0.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: colors.isDark ? colors.background : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.primary, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                if (_templateNameController.text.isNotEmpty) {
                  final newTemplate = UniformTemplate(
                    name: _templateNameController.text,
                    topIndex: _topColorIndex,
                    bottomIndex: _bottomColorIndex,
                    socksIndex: _socksColorIndex,
                  );
                  setState(() {
                    _savedTemplates.add(newTemplate);
                    _selectedUniformMode = newTemplate.name;
                    _showSaveTemplateForm = false;
                    _templateNameController.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Template "${newTemplate.name}" saved!'),
                      backgroundColor: colors.success,
                    ),
                  );
                }
              },
              child: Container(
                height: 48,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Save template',
                  style: AppTextStyles.heading16.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildAddOpponentInlineCard() {
    final colors = AppColors.current;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.isDark ? colors.card : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New opponent name',
            style: AppTextStyles.heading15.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _newOpponentNameController,
            style: AppTextStyles.body16.copyWith(color: colors.textPrimary),
            cursorColor: colors.primary,
            decoration: InputDecoration(
              hintText: 'e.g. Tulsa SC 09',
              hintStyle: AppTextStyles.body16.copyWith(color: colors.textSecondary.withValues(alpha: 0.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: colors.isDark ? colors.background : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.primary, width: 2.0),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                _saveOpponentForFuture = !_saveOpponentForFuture;
              });
            },
            child: Row(
              children: [
                SizedBox(
                  width: 25,
                  height: 25,
                  child: Checkbox(
                    value: _saveOpponentForFuture,
                    activeColor: colors.isDark ? colors.primary : const Color(0xFF2F54EB),
                    checkColor: Colors.white,
                    side: BorderSide(color: colors.textSecondary.withValues(alpha: 0.5), width: 1),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _saveOpponentForFuture = val);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Save this opponent for future games',
                    style: AppTextStyles.body14.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final name = _newOpponentNameController.text.trim();
                    if (name.isNotEmpty) {
                      setState(() {
                        if (_saveOpponentForFuture) {
                          _opponents.insert(_opponents.length - 1, name);
                        }
                        _selectedOpponent = name;
                        _showAddOpponentInline = false;
                        _newOpponentNameController.clear();
                      });
                    }
                  },
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Add opponent',
                      style: AppTextStyles.heading15.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAddOpponentInline = false;
                    _selectedOpponent = 'Select opponent...';
                    _newOpponentNameController.clear();
                  });
                },
                child: Text(
                  'Cancel',
                  style: AppTextStyles.heading15.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // _buildLocationSuggestionsCard removed — replaced by _showLocationOverlay()

  Widget _buildCustomTimePickerCard({required VoidCallback onTimeChanged}) {
    final colors = AppColors.current;
    
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: colors.isDark ? colors.card : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTimePickerColumn(
              items: List.generate(12, (index) => (index + 1).toString().padLeft(2, '0')),
              selectedValue: (_startTime.hour == 0 || _startTime.hour == 12) 
                  ? '12' 
                  : (_startTime.hour > 12 ? (_startTime.hour - 12).toString().padLeft(2, '0') : _startTime.hour.toString().padLeft(2, '0')),
              onSelected: (val) {
                final hourVal = int.parse(val);
                final isPm = _startTime.hour >= 12;
                setState(() {
                  _startTime = TimeOfDay(
                    hour: isPm ? (hourVal == 12 ? 12 : hourVal + 12) : (hourVal == 12 ? 0 : hourVal),
                    minute: _startTime.minute,
                  );
                });
                onTimeChanged();
              },
              useBlueBg: true,
            ),
          ),
          Expanded(
            child: _buildTimePickerColumn(
              items: List.generate(60, (index) => index.toString().padLeft(2, '0')),
              selectedValue: _startTime.minute.toString().padLeft(2, '0'),
              onSelected: (val) {
                setState(() {
                  _startTime = TimeOfDay(hour: _startTime.hour, minute: int.parse(val));
                });
                onTimeChanged();
              },
              useBlueBorder: true,
            ),
          ),
          Expanded(
            child: _buildTimePickerColumn(
              items: const ['AM', 'PM'],
              selectedValue: _startTime.hour >= 12 ? 'PM' : 'AM',
              onSelected: (val) {
                final currentHour12 = (_startTime.hour == 0 || _startTime.hour == 12) 
                    ? 12 
                    : (_startTime.hour > 12 ? _startTime.hour - 12 : _startTime.hour);
                setState(() {
                  _startTime = TimeOfDay(
                    hour: val == 'PM' ? (currentHour12 == 12 ? 12 : currentHour12 + 12) : (currentHour12 == 12 ? 0 : currentHour12),
                    minute: _startTime.minute,
                  );
                });
                onTimeChanged();
              },
              useBlueBg: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerColumn({
    required List<String> items,
    required String selectedValue,
    required ValueChanged<String> onSelected,
    bool useBlueBg = false,
    bool useBlueBorder = false,
  }) {
    final colors = AppColors.current;
    final initialIndex = items.indexOf(selectedValue);
    final controller = FixedExtentScrollController(initialItem: initialIndex >= 0 ? initialIndex : 0);

    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 36,
      perspective: 0.005,
      diameterRatio: 1.2,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) {
        if (index >= 0 && index < items.length) {
          onSelected(items[index]);
        }
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: items.length,
        builder: (context, index) {
          final item = items[index];
          final isSelected = item == selectedValue;

          return Center(
            child: isSelected
                ? (useBlueBg
                    ? Container(
                        height: 32,
                        width: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF008CFF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item,
                          style: AppTextStyles.heading15.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Container(
                        height: 32,
                        width: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.isDark ? colors.background : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF008CFF), width: 2.0),
                        ),
                        child: Text(
                          item,
                          style: AppTextStyles.heading15.copyWith(
                            color: const Color(0xFF008CFF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ))
                : Text(
                    item,
                    style: AppTextStyles.body15.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
