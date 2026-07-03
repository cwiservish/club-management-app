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
import '../providers/event_add_edit_provider.dart';
import '../models/new_event_dropdown_options_model.dart';
import '../models/new_event_save_request_model.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/models/club_event.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

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

// ─── Add / Edit Event Page ────────────────────────────────────────────────────

class AddEditEventPage extends ConsumerStatefulWidget {
  /// Non-null → edit mode; all fields pre-filled from this event.
  final ClubEvent? editEvent;

  const AddEditEventPage({super.key, this.editEvent});

  @override
  ConsumerState<AddEditEventPage> createState() => _AddEditEventPageState();
}

class _AddEditEventPageState extends ConsumerState<AddEditEventPage> {
  // Scheduling type key: 1=Single Session, 2=Tournament, 3=League (from API)
  int _schedulingTypeKey = 1;

  // Event type key from API (2=Practice default)
  int _eventTypeKey = 2;

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
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
  bool _chooseComboAsTemplate = false;
  String _uniformTemplateName = '';

  // Uniform template state
  // API templates come from dropdowns; locally added ones accumulate here
  final List<UniformTemplate> _localTemplates = [];
  // Tracks the selected API template (null = local template or new combo selected)
  NewEventUniformTemplate? _selectedApiTemplate;
  String _selectedUniformMode = 'New combo';

  // Opponent state
  // '' = nothing selected, '__new__' = add new inline open,
  // '__confirmed_new__' = new opponent confirmed but not yet saved to server,
  // otherwise = selected team ID as string
  String _selectedOpponentId = '';
  String _confirmedNewOpponentName = '';
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
  int _homeAwayKey = 1; // 1=Home, 2=Away, 3=Neutral (from API)
  int _arrivalTimeKey = 0; // 0=No set arrival time (from API)

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

  bool _hasPrefilledEdit = false;

  @override
  void initState() {
    super.initState();
    // Always re-fetch dropdowns on every open so data is fresh
    Future.microtask(() => ref.read(eventAddEditProvider.notifier).fetchNewEventDropdowns());
  }

  /// Maps a hex color string to the nearest index in [_uniformColors].
  /// Returns 0 (No color set) if no match found or hex is empty.
  int _hexToColorIndex(String hex) {
    if (hex.isEmpty) return 0;
    final normalized = hex.toUpperCase().replaceAll('#', '');
    for (int i = 0; i < _uniformColors.length; i++) {
      final c = _uniformColors[i];
      if (c.isNone) continue;
      final r = (c.color.r * 255).round().toRadixString(16).padLeft(2, '0');
      final g = (c.color.g * 255).round().toRadixString(16).padLeft(2, '0');
      final b = (c.color.b * 255).round().toRadixString(16).padLeft(2, '0');
      if ('$r$g$b'.toUpperCase() == normalized) return i;
    }
    return 0;
  }

  /// Pre-fills all form fields from [widget.editEvent] after dropdowns have loaded.
  /// Called once from [build] when dropdowns are available and edit mode is active.
  void _prefillFromEvent(NewEventDropdownOptions dropdowns) {
    if (widget.editEvent == null || _hasPrefilledEdit) return;
    final e = widget.editEvent!;
    setState(() {
      _hasPrefilledEdit = true;

      // Scheduling / event type
      _schedulingTypeKey = e.schedulingMode;
      _eventTypeKey = e.eventTypeKey;
      _homeAwayKey = e.homeAwayKey;
      _arrivalTimeKey = e.arrivalEarly;

      // Date & time (dateTime already parsed by home/schedule service)
      _selectedDate = DateUtils.dateOnly(e.dateTime);
      _startTime = TimeOfDay(hour: e.dateTime.hour, minute: e.dateTime.minute);

      // Duration
      _durationHours = e.duration.inHours;
      _durationMinutes = e.duration.inMinutes.remainder(60);

      // Location
      _locationController.text = e.location;
      _locationName = e.location;
      _latitude = e.latitude ?? '';
      _longitude = e.longitude ?? '';

      // Title (raw field, not display_name)
      _titleController.text = e.titleRaw;

      // Notes
      _notesController.text = e.notes ?? '';

      // Tournament/League
      _knowsSchedule = e.isFullSchedule;
      _startDate = e.startDate;
      _endDate = e.endDate;

      // Opponent
      if (e.opponentTeamId > 0) {
        final inList = dropdowns.teams.any((t) => t.id == e.opponentTeamId);
        if (inList) {
          _selectedOpponentId = e.opponentTeamId.toString();
        } else {
          // Team not in dropdown list — treat as confirmed new opponent
          _confirmedNewOpponentName = e.opponent ?? '';
          _selectedOpponentId = '__confirmed_new__';
        }
      } else if (e.opponent != null && e.opponent!.isNotEmpty) {
        _confirmedNewOpponentName = e.opponent!;
        _selectedOpponentId = '__confirmed_new__';
      }

      // Uniform
      if (e.uniformTemplateId > 0) {
        final template = dropdowns.uniformTemplates
            .where((t) => t.id == e.uniformTemplateId)
            .firstOrNull;
        if (template != null) {
          _selectedApiTemplate = template;
          _selectedUniformMode = template.templateName;
        } else {
          // Template not in list — fall back to hex colors
          _topColorIndex = _hexToColorIndex(e.uniformTopColor);
          _bottomColorIndex = _hexToColorIndex(e.uniformBottomColor);
          _socksColorIndex = _hexToColorIndex(e.uniformSocksColor);
          _selectedUniformMode = 'New combo';
        }
      } else if (e.uniformTopColor.isNotEmpty || e.uniformBottomColor.isNotEmpty || e.uniformSocksColor.isNotEmpty) {
        _topColorIndex = _hexToColorIndex(e.uniformTopColor);
        _bottomColorIndex = _hexToColorIndex(e.uniformBottomColor);
        _socksColorIndex = _hexToColorIndex(e.uniformSocksColor);
        _selectedUniformMode = 'New combo';
      }
    });
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


  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _colorToHex(UniformColor c) {
    if (c.isNone) return '';
    final r = c.color.red.toRadixString(16).padLeft(2, '0');
    final g = c.color.green.toRadixString(16).padLeft(2, '0');
    final b = c.color.blue.toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  String _formatSessionDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatStartTime24(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Returns uniform fields for the save request based on current selection.
  // API template selected → send id only. Local combo → send colors (+ template flag if saved).
  ({
    String templateId,
    String topColor,
    String bottomColor,
    String socksColor,
    bool chooseCombo,
    String templateName,
  }) _buildUniformFields() {
    if (_selectedApiTemplate != null) {
      return (
        templateId: _selectedApiTemplate!.id.toString(),
        topColor: '',
        bottomColor: '',
        socksColor: '',
        chooseCombo: false,
        templateName: '',
      );
    }
    return (
      templateId: '',
      topColor: _colorToHex(_uniformColors[_topColorIndex]),
      bottomColor: _colorToHex(_uniformColors[_bottomColorIndex]),
      socksColor: _colorToHex(_uniformColors[_socksColorIndex]),
      chooseCombo: _chooseComboAsTemplate,
      templateName: _uniformTemplateName,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.current.error),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final colors = AppColors.current;
        return AlertDialog(
          backgroundColor: colors.isDark ? colors.card : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Something went wrong',
            style: AppTextStyles.heading16.copyWith(color: colors.textPrimary),
          ),
          content: Text(
            message,
            style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK', style: AppTextStyles.body14.copyWith(color: colors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _handleSaveResult(bool success) {
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Event saved - families will be notified'),
          backgroundColor: AppColors.current.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(AppRoutes.home);
    } else {
      _showErrorDialog(
        ref.read(eventAddEditProvider).newEventSaveError ?? 'Failed to create event',
      );
    }
  }

  void _onSave() => _doSave();

  Future<void> _doSave() async {
    if (ref.read(eventAddEditProvider).isSavingNewEvent) return;

    // Edit-mode values ('' / 0 for create mode)
    final editId = widget.editEvent?.dbId?.toString() ?? '';
    final existingSchedulingMode = widget.editEvent?.existingSchedulingMode ?? '';
    final editStatus = widget.editEvent?.status.toString() ?? '';

    // ── Flow 1: Single Session ─────────────────────────────────────────────
    if (_schedulingTypeKey == 1) {
      if (_selectedDate == null) {
        _showError('Please select a date');
        return;
      }

      final locationText = _locationController.text.trim();
      if (locationText.isEmpty) {
        _showError('Please enter a location');
        return;
      }

      // Title vs Opponent depending on event type
      String title = '';
      String opponentTeamId = '';
      String opponentTeamName = '';
      bool allowForFutureGames = false;

      final isGameOrScrimmage = _eventTypeKey == 1 || _eventTypeKey == 3;
      if (isGameOrScrimmage) {
        // Flow 1: Game or Scrimmage — opponent is required
        if (_selectedOpponentId == '__confirmed_new__') {
          // New opponent was confirmed via "Add opponent" button
          opponentTeamName = _confirmedNewOpponentName;
          allowForFutureGames = _saveOpponentForFuture;
        } else if (_selectedOpponentId.isNotEmpty && _selectedOpponentId != '__new__') {
          // Existing team selected from API list — send ID only
          opponentTeamId = _selectedOpponentId;
          allowForFutureGames = false;
        } else {
          _showError('Please select or add an opponent');
          return;
        }
      } else {
        // Flow 2: Practice, Team Event, Camp — title is required, no opponent
        title = _titleController.text.trim();
        if (title.isEmpty) {
          _showError('Please enter a title');
          return;
        }
        allowForFutureGames = false;
      }

      final activeTeam = ref.read(selectedTeamProvider);
      if (activeTeam == null) {
        _showError('No active team selected');
        return;
      }

      final request = NewEventSaveRequest(
        teamUuid: activeTeam.uuid,
        id: editId,
        existingSchedulingMode: existingSchedulingMode,
        status: editStatus,
        schedulingMode: _schedulingTypeKey,
        eventType: _eventTypeKey,
        title: title,
        sessionDate: _formatSessionDate(_selectedDate!),
        startTime: _formatStartTime24(_startTime),
        duration: _durationHours * 60 + _durationMinutes,
        homeAway: isGameOrScrimmage ? _homeAwayKey : 0,
        arrivalEarly: isGameOrScrimmage ? _arrivalTimeKey : 0,
        location: _locationName.isNotEmpty ? _locationName : locationText,
        latitude: _latitude,
        longitude: _longitude,
        opponentTeamId: opponentTeamId,
        opponentTeamName: opponentTeamName,
        allowForFutureGames: allowForFutureGames,
        uniformTemplateId: _buildUniformFields().templateId,
        uniformTopColor: _buildUniformFields().topColor,
        uniformBottomColor: _buildUniformFields().bottomColor,
        uniformSocksColor: _buildUniformFields().socksColor,
        chooseComboAsTemplate: _buildUniformFields().chooseCombo,
        uniformTemplateName: _buildUniformFields().templateName,
        notes: _notesController.text,
      );

      final success = await ref.read(eventAddEditProvider.notifier).saveNewEvent(request);
      _handleSaveResult(success);
      return;
    }

    // ── Flows 3 & 4: Tournament / League ──────────────────────────────────
    if (_schedulingTypeKey == 2 || _schedulingTypeKey == 3) {
      if (!_knowsSchedule) {
        // Flow 3: Placeholder — date range only
        final title = _titleController.text.trim();
        if (title.isEmpty) {
          _showError('Please enter a title');
          return;
        }
        if (_startDate == null) {
          _showError('Please select a start date');
          return;
        }
        if (_endDate == null) {
          _showError('Please select an end date');
          return;
        }
        final locationText = _locationController.text.trim();
        if (locationText.isEmpty) {
          _showError('Please enter a location');
          return;
        }

        final activeTeam = ref.read(selectedTeamProvider);
        if (activeTeam == null) {
          _showError('No active team selected');
          return;
        }

        final request = NewEventSaveRequest(
          teamUuid: activeTeam.uuid,
          id: editId,
          existingSchedulingMode: existingSchedulingMode,
          status: editStatus,
          schedulingMode: _schedulingTypeKey,
          eventType: 0,
          title: title,
          sessionDate: '',
          startTime: '',
          duration: 0,
          homeAway: 0,
          arrivalEarly: 0,
          location: _locationName.isNotEmpty ? _locationName : locationText,
          latitude: _latitude,
          longitude: _longitude,
          opponentTeamName: '',
          allowForFutureGames: false,
          uniformTopColor: '',
          uniformBottomColor: '',
          uniformSocksColor: '',
          chooseComboAsTemplate: false,
          uniformTemplateName: '',
          startDate: _formatSessionDate(_startDate!),
          endDate: _formatSessionDate(_endDate!),
          notes: _notesController.text,
        );

        final success = await ref.read(eventAddEditProvider.notifier).saveNewEvent(request);
        _handleSaveResult(success);
        return;
      }

      // Flow 4: Yes, I have the schedule — title not required, sent as empty
      if (_selectedDate == null) {
        _showError('Please select a date');
        return;
      }
      final locationText = _locationController.text.trim();
      if (locationText.isEmpty) {
        _showError('Please enter a location');
        return;
      }

      final activeTeam = ref.read(selectedTeamProvider);
      if (activeTeam == null) {
        _showError('No active team selected');
        return;
      }

      // Flow 4: "Yes I have it" → same opponent logic as flow 1
      String flow4OpponentTeamId = '';
      String flow4OpponentTeamName = '';
      bool flow4AllowForFutureGames = false;

      if (_selectedOpponentId == '__confirmed_new__') {
        flow4OpponentTeamName = _confirmedNewOpponentName;
        flow4AllowForFutureGames = _saveOpponentForFuture;
      } else if (_selectedOpponentId.isNotEmpty && _selectedOpponentId != '__new__') {
        flow4OpponentTeamId = _selectedOpponentId;
        flow4AllowForFutureGames = false;
      } else {
        _showError('Please select or add an opponent');
        return;
      }

      // Flow 4: "Yes I have it" → always sent as single session game (scheduling_mode=1, event_type=1)
      final request = NewEventSaveRequest(
        teamUuid: activeTeam.uuid,
        id: editId,
        existingSchedulingMode: existingSchedulingMode,
        status: editStatus,
        schedulingMode: 1,
        eventType: 1,
        title: '',
        sessionDate: _formatSessionDate(_selectedDate!),
        startTime: _formatStartTime24(_startTime),
        duration: _durationHours * 60 + _durationMinutes,
        homeAway: _homeAwayKey,
        arrivalEarly: _arrivalTimeKey,
        location: _locationName.isNotEmpty ? _locationName : locationText,
        latitude: _latitude,
        longitude: _longitude,
        opponentTeamId: flow4OpponentTeamId,
        opponentTeamName: flow4OpponentTeamName,
        allowForFutureGames: flow4AllowForFutureGames,
        uniformTemplateId: _buildUniformFields().templateId,
        uniformTopColor: _buildUniformFields().topColor,
        uniformBottomColor: _buildUniformFields().bottomColor,
        uniformSocksColor: _buildUniformFields().socksColor,
        chooseComboAsTemplate: _buildUniformFields().chooseCombo,
        uniformTemplateName: _buildUniformFields().templateName,
        notes: _notesController.text,
      );

      final success = await ref.read(eventAddEditProvider.notifier).saveNewEvent(request);
      _handleSaveResult(success);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final colors = AppColors.current;
    final dropdownState = ref.watch(eventAddEditProvider);
    final isEditMode = widget.editEvent != null;

    // Pre-fill once dropdowns are ready in edit mode
    if (isEditMode && dropdownState.newEventDropdowns != null && !_hasPrefilledEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prefillFromEvent(dropdownState.newEventDropdowns!);
      });
    }

    final subHeader = SubHeader(
      title: isEditMode ? 'Edit Event' : 'New Event',
      leftIcon: Icons.close,
      leftLabel: 'Close',
      onLeftTap: () => context.pop(),
      rightText: 'Save',
      onRightTap: (dropdownState.isLoadingNewEventDropdowns || dropdownState.isSavingNewEvent) ? null : _onSave,
    );

    // Full-screen loader while fetching dropdown options
    if (dropdownState.isLoadingNewEventDropdowns) {
      return Scaffold(
        backgroundColor: colors.isDark ? colors.background : const Color(0xFFF4F5F7),
        body: SafeArea(
          child: Column(
            children: [
              subHeader,
              Expanded(child: Center(child: CircularProgressIndicator(color: colors.primary))),
            ],
          ),
        ),
      );
    }

    // Retry screen if API failed
    if (dropdownState.newEventDropdownsError != null) {
      return Scaffold(
        backgroundColor: colors.isDark ? colors.background : const Color(0xFFF4F5F7),
        body: SafeArea(
          child: Column(
            children: [
              subHeader,
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Failed to load form options',
                        style: AppTextStyles.body16.copyWith(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(eventAddEditProvider.notifier).fetchNewEventDropdowns(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Retry'),
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

    final dropdowns = dropdownState.newEventDropdowns!;

    return Scaffold(
      backgroundColor: colors.isDark ? colors.background : const Color(0xFFF4F5F7),
      body: SafeArea(
        child: Column(
          children: [
            subHeader,
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'New Event',
                      style: AppTextStyles.heading22.copyWith(color: colors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFormContainer(dropdowns),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContainer(NewEventDropdownOptions dropdowns) {
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
              for (int i = 0; i < dropdowns.schedulingTypes.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _buildCategoryButton(dropdowns.schedulingTypes[i].key, dropdowns.schedulingTypes[i].label),
              ],
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
          if (_schedulingTypeKey == 1) ...[
            _buildSingleSessionForm(dropdowns)
          ] else if (_schedulingTypeKey == 2) ...[
            _buildTournamentForm(dropdowns)
          ] else if (_schedulingTypeKey == 3) ...[
            _buildLeagueForm(dropdowns)
          ]
        ],
      ),
    );
  }

  String _getCategorySubtext() {
    if (_schedulingTypeKey == 1) {
      return 'A single game, practice, or team event with a known date and time. Add one for each session if you have several in a day.';
    } else if (_schedulingTypeKey == 2) {
      return 'A multi-day tournament. You usually know the date range months ahead but not each game time until closer — add it as a placeholder now and fill in games later.';
    } else {
      return 'A league season spanning several weeks. Add the date range now; fill in individual game dates and times as the league publishes them.';
    }
  }

  Widget _buildCategoryButton(int key, String label) {
    final colors = AppColors.current;
    final isSelected = _schedulingTypeKey == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _schedulingTypeKey = key),
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
    final isSaving = ref.watch(eventAddEditProvider).isSavingNewEvent;
    String buttonText = 'Save';
    if (_schedulingTypeKey == 1) {
      buttonText = 'Save event';
    } else {
      buttonText = _knowsSchedule ? 'Save event' : 'Save placeholder';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: isSaving ? null : _onSave,
          child: Container(
            height: 48,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : Text(
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
  Widget _buildSingleSessionForm(NewEventDropdownOptions dropdowns) {
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
          children: dropdowns.eventTypes.map((type) => _buildEventTypeChip(type)).toList(),
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
        if (_eventTypeKey == 1 || _eventTypeKey == 3) ...[
          _buildOpponentSection(dropdowns),
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
        if (_eventTypeKey == 1 || _eventTypeKey == 3) ...[
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
                  for (int i = 0; i < dropdowns.homeAwayOptions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    _buildHomeOrAwayButton(dropdowns.homeAwayOptions[i]),
                  ],
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
              _buildDropdownField<int>(
                value: _arrivalTimeKey,
                items: dropdowns.arrivalTimeOptions.map((o) => o.key).toList(),
                itemLabel: (key) => dropdowns.arrivalTimeOptions
                    .firstWhere((o) => o.key == key, orElse: () => const NewEventArrivalTimeOption(key: 0, label: 'No set arrival time'))
                    .label,
                onChanged: (val) {
                  if (val != null) setState(() => _arrivalTimeKey = val);
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
        _buildUniformFormContent(dropdowns),
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
  Widget _buildTournamentForm(NewEventDropdownOptions dropdowns) {
    return _buildSharedMultiDayForm(dropdowns: dropdowns,
      titlePlaceholder: 'e.g. Spring Showcase Tournament',
    );
  }

  // ── League Form ──
  Widget _buildLeagueForm(NewEventDropdownOptions dropdowns) {
    return _buildSharedMultiDayForm(dropdowns: dropdowns,
      titlePlaceholder: 'e.g. Fall ECNL RL League',
    );
  }

  // Tournament and League share a very similar structure
  Widget _buildSharedMultiDayForm({required String titlePlaceholder, required NewEventDropdownOptions dropdowns}) {
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
        // Title for placeholder mode / Opponent for "Yes, I have it"
        if (!_knowsSchedule) ...[
          _buildTextField(
            label: 'Title',
            hintText: titlePlaceholder,
            controller: _titleController,
          ),
        ] else ...[
          _buildOpponentSection(dropdowns),
        ],
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
                  for (int i = 0; i < dropdowns.homeAwayOptions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    _buildHomeOrAwayButton(dropdowns.homeAwayOptions[i]),
                  ],
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
              _buildDropdownField<int>(
                value: _arrivalTimeKey,
                items: dropdowns.arrivalTimeOptions.map((o) => o.key).toList(),
                itemLabel: (key) => dropdowns.arrivalTimeOptions
                    .firstWhere((o) => o.key == key, orElse: () => const NewEventArrivalTimeOption(key: 0, label: 'No set arrival time'))
                    .label,
                onChanged: (val) {
                  if (val != null) setState(() => _arrivalTimeKey = val);
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
          _buildUniformFormContent(dropdowns),
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

  // Event type keys: 1=Game, 2=Practice, 3=Scrimmage, 4=Team Event, 5=Camp
  Color _getEventTypeBgColor(int key, bool isSelected) {
    if (!isSelected) return Colors.transparent;
    switch (key) {
      case 1: return const Color(0xFFFFC107); // Game
      case 2: return const Color(0xFF00E5FF); // Practice
      case 3: return const Color(0xFF2F54EB); // Scrimmage
      case 4: return const Color(0xFFE91E63); // Team Event
      case 5: return const Color(0xFF00C853); // Camp
      default: return const Color(0xFF00E5FF);
    }
  }

  Color _getEventTypeTextColor(int key, bool isSelected) {
    final colors = AppColors.current;
    if (!isSelected) return colors.textSecondary;
    switch (key) {
      case 1:
      case 2: return Colors.black;
      case 3:
      case 4:
      case 5: return Colors.white;
      default: return Colors.black;
    }
  }

  Widget _buildHomeOrAwayButton(NewEventHomeAwayOption option) {
    final colors = AppColors.current;
    final isSelected = _homeAwayKey == option.key;
    return GestureDetector(
      onTap: () => setState(() => _homeAwayKey = option.key),
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
          option.label,
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

  Widget _buildEventTypeChip(NewEventType type) {
    final colors = AppColors.current;
    final isSelected = _eventTypeKey == type.key;

    final selectedColor = _getEventTypeBgColor(type.key, isSelected);
    final textColor = _getEventTypeTextColor(type.key, isSelected);
    final borderColor = isSelected ? selectedColor : colors.border;

    return GestureDetector(
      onTap: () => setState(() => _eventTypeKey = type.key),
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
          type.label,
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

  Widget _buildUniformFormContent(NewEventDropdownOptions dropdowns) {
    final colors = AppColors.current;
    final apiTemplates = dropdowns.uniformTemplates;
    final hasAnyTemplates = apiTemplates.isNotEmpty || _localTemplates.isNotEmpty;
    final isNewCombo = _selectedApiTemplate == null && _selectedUniformMode == 'New combo';
    final showColorPickers = isNewCombo || !hasAnyTemplates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Template tabs — only shown when there's at least 1 template
        if (hasAnyTemplates) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final t in apiTemplates) ...[
                  _buildUniformTemplateTab(
                    label: t.templateName,
                    isSelected: _selectedApiTemplate?.id == t.id,
                    onTap: () => setState(() {
                      _selectedUniformMode = t.templateName;
                      _selectedApiTemplate = t;
                      _chooseComboAsTemplate = false;
                      _uniformTemplateName = '';
                    }),
                  ),
                  const SizedBox(width: 10),
                ],
                for (final t in _localTemplates) ...[
                  _buildUniformTemplateTab(
                    label: t.name,
                    isSelected: _selectedApiTemplate == null && _selectedUniformMode == t.name,
                    onTap: () => setState(() {
                      _selectedUniformMode = t.name;
                      _selectedApiTemplate = null;
                      _topColorIndex = t.topIndex;
                      _bottomColorIndex = t.bottomIndex;
                      _socksColorIndex = t.socksIndex;
                      _chooseComboAsTemplate = false;
                      _uniformTemplateName = '';
                    }),
                  ),
                  const SizedBox(width: 10),
                ],
                _buildUniformTemplateTab(
                  label: 'New combo',
                  isSelected: isNewCombo,
                  onTap: () => setState(() {
                    _selectedUniformMode = 'New combo';
                    _selectedApiTemplate = null;
                    _chooseComboAsTemplate = false;
                    _uniformTemplateName = '';
                  }),
                ),
              ],
            ),
          ),
        ],

        // Color pickers — shown in new combo mode or when no templates exist
        if (showColorPickers) ...[
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

          GestureDetector(
            onTap: () => setState(() => _showSaveTemplateForm = !_showSaveTemplateForm),
            child: Text(
              'Save this combo as a template',
              style: AppTextStyles.body14.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_showSaveTemplateForm) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _templateNameController,
              onChanged: (_) => setState(() {}),
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
            Builder(
              builder: (_) {
                final canSave = _templateNameController.text.trim().isNotEmpty;
                return GestureDetector(
                  onTap: canSave
                      ? () {
                          final name = _templateNameController.text.trim();
                          final newTemplate = UniformTemplate(
                            name: name,
                            topIndex: _topColorIndex,
                            bottomIndex: _bottomColorIndex,
                            socksIndex: _socksColorIndex,
                          );
                          setState(() {
                            _localTemplates.add(newTemplate);
                            _selectedUniformMode = name;
                            _selectedApiTemplate = null;
                            _chooseComboAsTemplate = true;
                            _uniformTemplateName = name;
                            _showSaveTemplateForm = false;
                            _templateNameController.clear();
                          });
                        }
                      : null,
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: canSave ? const Color(0xFF00E5FF) : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Save template',
                      style: AppTextStyles.heading16.copyWith(
                        color: canSave ? Colors.black : const Color(0xFFAAAAAA),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildUniformTemplateTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = AppColors.current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOpponentSection(NewEventDropdownOptions dropdowns) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opponent',
          style: AppTextStyles.heading14.copyWith(color: AppColors.current.textPrimary),
        ),
        const SizedBox(height: 8),
        _buildDropdownField<String>(
          value: _selectedOpponentId,
          items: [
            '',
            ...dropdowns.teams.map((t) => t.id.toString()),
            if (_selectedOpponentId == '__confirmed_new__') '__confirmed_new__',
            '__new__',
          ],
          itemLabel: (v) {
            if (v == '') return 'Select opponent...';
            if (v == '__new__') return '+ Add a new opponent...';
            if (v == '__confirmed_new__') return _confirmedNewOpponentName;
            final match = dropdowns.teams.where((t) => t.id.toString() == v).firstOrNull;
            return match?.name ?? v;
          },
          onChanged: (val) {
            if (val == '__new__') {
              setState(() {
                _showAddOpponentInline = true;
                _selectedOpponentId = '__new__';
                _confirmedNewOpponentName = '';
              });
            } else if (val != null) {
              setState(() {
                _selectedOpponentId = val;
                _showAddOpponentInline = false;
                _confirmedNewOpponentName = '';
              });
            }
          },
        ),
        if (_showAddOpponentInline) ...[
          const SizedBox(height: 12),
          _buildAddOpponentInlineCard(),
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
                        _confirmedNewOpponentName = name;
                        _selectedOpponentId = '__confirmed_new__';
                        _showAddOpponentInline = false;
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
                    _selectedOpponentId = '';
                    _confirmedNewOpponentName = '';
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
