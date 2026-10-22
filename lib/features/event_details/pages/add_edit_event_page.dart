import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../models/uniform_color.dart';
import '../models/new_event_save_request_model.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/common_providers/event_refresh_provider.dart';
import '../../../core/models/club_event.dart';
import '../widgets/event_edit_danger_card.dart';
import '../utils/duplicate_event_helper.dart';
import '../widgets/event_location_tab_view.dart';
import '../widgets/event_repeats_until_section.dart';
import '../../roster/providers/roster_provider.dart';
import '../../roster/models/roster_member.dart';
import '../../../core/enums/member_role.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

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

  /// Where the user came from — 'home' or 'schedule'. Used for post-save navigation.
  final String origin;

  /// True → pre-fill from [editEvent] but save as a brand-new event (no id sent).
  final bool isDuplicate;

  /// When set, hides the "What are you adding?" section and locks scheduling type to this value.
  final int? defaultSchedulingTypeKey;

  /// When set, hides the "Event type" section and locks event type to this value.
  final int? defaultEventTypeKey;

  /// The parent league/tournament [ClubEvent]. When provided:
  /// - date picker is restricted to its start/end date range
  /// - save request sends event_from=1 and event_id=parentEvent.id
  final ClubEvent? parentEvent;

  /// Optional page title override. Defaults to 'New Event' in create mode.
  final String? title;

  const AddEditEventPage({
    super.key,
    this.editEvent,
    this.origin = 'home',
    this.isDuplicate = false,
    this.defaultSchedulingTypeKey,
    this.defaultEventTypeKey,
    this.parentEvent,
    this.title,
  });

  @override
  ConsumerState<AddEditEventPage> createState() => _AddEditEventPageState();
}

class _AddEditEventPageState extends ConsumerState<AddEditEventPage> with WidgetsBindingObserver {
  // Scheduling type key: 1=Single Session, 2=Tournament, 3=League (from API)
  int _schedulingTypeKey = 1;

  // Event type key from API (2=Practice default)
  int _eventTypeKey = 2;

  // Cancel Event toggle — status 2 = cancelled, 1 = active
  bool _isCancelled = false;

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
  final LayerLink _locationLayerLink = LayerLink();

  // Web UI Tab Navigation: 0=Details, 1=Location, 2=Uniform, 3=RSVP
  int _selectedTabIndex = 0;

  // RSVP selection state
  Set<String> _selectedAthleteIds = {};
  Set<String> _selectedStaffIds = {};
  bool _hasInitializedRsvpSelection = false;

  // Repeats Until state
  bool _isRepeating = false;
  String _repeatType = 'Weekly'; // 'Weekly' or 'Monthly'
  DateTime? _repeatUntilDate;
  late List<WeeklySlotConfig> _weeklySlots;
  Set<DateTime> _selectedMonthlyDates = {};
  DateTime _selectedMonth = DateTime.now();

  // Location Tab Mode & Selections
  EventLocationMode _locationMode = EventLocationMode.ourLocations;
  OurLocationVenue? _selectedVenue;
  OurLocationField? _selectedFieldItem;
  SavedLocationItem? _selectedSavedLocationItem;

  // Detailed address components for off-site address
  String _address = '';
  String _city = '';
  String _state = '';
  String _country = '';
  String _postalCode = '';
  String _placeId = '';

  /// `venues` field names already start with the facility name
  /// ("ABC FACILITY - Resource A"), so avoid repeating it.
  String _venueFieldName(OurLocationVenue venue, OurLocationField field) {
    return field.fieldName.startsWith(venue.name)
        ? field.fieldName
        : '${venue.name} - ${field.fieldName}';
  }

  String? _resolveLocationText() {
    switch (_locationMode) {
      case EventLocationMode.ourLocations:
        if (_selectedVenue != null) {
          if (_selectedFieldItem != null) {
            return _venueFieldName(_selectedVenue!, _selectedFieldItem!);
          }
          return _selectedVenue!.name;
        }
        return null;

      case EventLocationMode.savedLocation:
        if (_selectedSavedLocationItem != null) {
          return _selectedSavedLocationItem!.name.isNotEmpty
              ? _selectedSavedLocationItem!.name
              : _selectedSavedLocationItem!.location;
        }
        return null;

      case EventLocationMode.offSiteAddress:
        final addr = _locationController.text.trim();
        if (addr.isEmpty) return null;
        return addr;

      case EventLocationMode.tbd:
        return 'TBD';
    }
  }

  ({
    int locationType,
    int? venueId,
    int? fieldId,
    int? savedLocationId,
    String address,
    String city,
    String state,
    String country,
    String postalCode,
    String placeId,
    String latitude,
    String longitude,
    String locationName,
  }) _extractLocationData() {
    int locationType = 1;
    int? venueId;
    int? fieldId;
    int? savedLocationId;
    String address = _address;
    String city = _city;
    String state = _state;
    String country = _country;
    String postalCode = _postalCode;
    String placeId = _placeId;
    String latitude = _latitude;
    String longitude = _longitude;
    String locationName = _locationName;

    switch (_locationMode) {
      case EventLocationMode.ourLocations:
        locationType = 1;
        venueId = _selectedVenue?.venueId;
        fieldId = _selectedFieldItem?.fieldId;
        if (_selectedVenue != null) {
          latitude = _selectedVenue!.latitude;
          longitude = _selectedVenue!.longitude;
          locationName = _selectedFieldItem != null
              ? _venueFieldName(_selectedVenue!, _selectedFieldItem!)
              : _selectedVenue!.name;
        }
        break;

      case EventLocationMode.savedLocation:
        locationType = 2;
        savedLocationId = _selectedSavedLocationItem?.savedLocationId ?? _selectedSavedLocationItem?.id;
        if (_selectedSavedLocationItem != null) {
          final s = _selectedSavedLocationItem!;
          address = s.address.isNotEmpty ? s.address : s.location;
          locationName = s.name.isNotEmpty ? s.name : s.location;
          latitude = s.latitude;
          longitude = s.longitude;
          city = s.city;
          state = s.state;
          country = s.country;
          postalCode = s.postalCode;
          placeId = s.placeId;
        }
        break;

      case EventLocationMode.offSiteAddress:
        locationType = 3;
        final rawAddr = _locationController.text.trim();
        if (address.isEmpty) {
          address = rawAddr;
        }
        locationName = address;
        break;

      case EventLocationMode.tbd:
        locationType = 4;
        locationName = 'TBD';
        address = '';
        city = '';
        state = '';
        country = '';
        postalCode = '';
        placeId = '';
        latitude = '';
        longitude = '';
        break;
    }

    return (
      locationType: locationType,
      venueId: venueId,
      fieldId: fieldId,
      savedLocationId: savedLocationId,
      address: address,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
      placeId: placeId,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );
  }

  // Save template states
  bool _showSaveTemplateForm = false;
  final _templateNameController = TextEditingController();

  // Uniform template state
  // API templates come from dropdowns; locally added ones accumulate here
  final List<UniformTemplate> _localTemplates = [];
  // Tracks the selected API template (null = local template or new combo selected)
  NewEventUniformTemplate? _selectedApiTemplate;
  String _selectedUniformMode = 'New combo';

  // Opponent state
  // '' = nothing selected, '__new__' = add new inline open,
  // otherwise = selected team ID as string
  String _selectedOpponentId = '';
  bool _showAddOpponentInline = false;
  bool _saveOpponentForFuture = true;
  final _newOpponentNameController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 17, minute: 0); // 05:00 PM default as shown in web UI
  int _durationHours = 1;
  int _durationMinutes = 30;
  // Custom Time Picker overlay
  final GlobalKey _startTimeFieldKey = GlobalKey();
  final LayerLink _startTimeLayerLink = LayerLink();
  OverlayEntry? _timePickerOverlay;
  int _homeAwayKey = 1; // 1=Home (default as shown in web UI), 2=Away, 3=Neutral
  int _arrivalTimeKey = 0; // 0=No set arrival time (from API)

  // Tournament/League specific state
  bool _knowsSchedule = false; // false = Not yet — placeholder, true = Yes, I have it
  DateTime? _startDate;
  DateTime? _endDate;

  // Uniform Pickers State (Selected color index)
  // Dynamic: item name (from API `uniform_items`) -> index into kUniformColors
  final Map<String, int> _uniformColorIdx = {};
  List<String> _uniformItems = const ['top', 'bottom', 'socks'];
  int get _topColorIndex => _uniformColorIdx['top'] ?? 0;
  set _topColorIndex(int v) => _uniformColorIdx['top'] = v;
  int get _bottomColorIndex => _uniformColorIdx['bottom'] ?? 0;
  set _bottomColorIndex(int v) => _uniformColorIdx['bottom'] = v;
  int get _socksColorIndex => _uniformColorIdx['socks'] ?? 0;
  set _socksColorIndex(int v) => _uniformColorIdx['socks'] = v;

  /// Hex (or '' for none) for every uniform item currently selected.
  Map<String, String> _currentUniformHex() => {
        for (final item in _uniformItems)
          item: uniformColorToHex(kUniformColors[_uniformColorIdx[item] ?? 0]),
      };

  /// `uniform` payload: {item: "#hex" | null}. Null when a template id is sent
  /// or no color is chosen.
  Map<String, dynamic>? _buildUniformMap(String templateId) {
    if (templateId.isNotEmpty) return null;
    final hex = _currentUniformHex();
    if (hex.values.every((v) => v.isEmpty)) return null;
    return {for (final e in hex.entries) e.key: e.value.isNotEmpty ? e.value : null};
  }

  void _applyTemplateColors(NewEventUniformTemplate t) {
    for (final item in _uniformItems) {
      final hex = t.colors[item] ??
          (item == 'top' ? t.topColor : item == 'bottom' ? t.bottomColor : item == 'socks' ? t.socksColor : '');
      _uniformColorIdx[item] = hexToColorIndex(hex);
    }
  }

  // ─── Single Active Dropdown / Overlay Dismissal ──────────────────────────────

  void _closeAllDropdowns({bool unfocus = false}) {
    _hideLocationOverlay();
    _removeTimePickerOverlay();
    if (unfocus && mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  // ─── Location Overlay ────────────────────────────────────────────────────────

  void _showLocationOverlay() {
    _removeTimePickerOverlay();

    final renderBox = _locationFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    if (_locationOverlay != null) {
      _locationOverlay!.markNeedsBuild();
      return;
    }

    _locationOverlay = OverlayEntry(
      builder: (_) {
        final colors = AppColors.current;
        final box = _locationFieldKey.currentContext?.findRenderObject() as RenderBox?;
        final width = box?.size.width ?? (MediaQuery.of(context).size.width - 38);

        return Stack(
          children: [
            CompositedTransformFollower(
              link: _locationLayerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: const Offset(0, 4),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: width,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: colors.isDark ? colors.card : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
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
    _removeTimePickerOverlay();
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
        _address = item['address']?.toString() ?? item['description']?.toString() ?? _locationName;
        _city = item['city']?.toString() ?? '';
        _state = item['state']?.toString() ?? '';
        _country = item['country']?.toString() ?? '';
        _postalCode = item['postal_code']?.toString() ?? '';
        _placeId = item['place_id']?.toString() ?? '';
        _locationController.text = _address.isNotEmpty ? _address : _locationName;
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

        String formattedAddress = details?['formatted_address']?.toString() ?? item['description']?.toString() ?? name;
        String city = '';
        int cityRank = 99; // lower = better match
        String state = '';
        String country = '';
        String postalCode = '';

        final components = details?['address_components'];
        if (components is List) {
          for (final c in components) {
            if (c is Map) {
              final types = (c['types'] as List? ?? []).map((t) => t.toString()).toList();
              final longName = c['long_name']?.toString() ?? '';
              final shortName = c['short_name']?.toString() ?? '';
              const cityTypes = ['locality', 'postal_town', 'administrative_area_level_2', 'sublocality'];
              for (int i = 0; i < cityTypes.length; i++) {
                if (types.contains(cityTypes[i]) && i < cityRank) {
                  cityRank = i;
                  city = longName;
                }
              }
              if (types.contains('administrative_area_level_1')) {
                state = shortName.isNotEmpty ? shortName : longName;
              }
              if (types.contains('country')) {
                country = shortName.isNotEmpty ? shortName : longName;
              }
              if (types.contains('postal_code')) {
                postalCode = longName;
              }
            }
          }
        }

        setState(() {
          _locationName = name;
          _address = formattedAddress;
          _city = city;
          _state = state;
          _country = country;
          _postalCode = postalCode;
          _placeId = placeId;
          _latitude = details?['geometry']?['location']?['lat']?.toString() ?? '';
          _longitude = details?['geometry']?['location']?['lng']?.toString() ?? '';
          _locationController.text = formattedAddress;
          _isLoadingLocation = false;
        });
        _hideLocationOverlay();
      }
    }
  }

  void _showStartTimeOverlay() {
    _closeAllDropdowns();
    _clampStartTimeToNowIfToday(); // ensure wheel opens at a valid time

    final renderBox = _startTimeFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _timePickerOverlay = OverlayEntry(
      builder: (_) {
        final box = _startTimeFieldKey.currentContext?.findRenderObject() as RenderBox?;
        final width = box?.size.width;

        return Stack(
          children: [
            CompositedTransformFollower(
              link: _startTimeLayerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: const Offset(0, 4),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: width,
                  child: GestureDetector(
                    onTap: () {},
                    child: _buildCustomTimePickerCard(
                      onTimeChanged: () {
                        setState(() => _clampStartTimeToNowIfToday());
                        _timePickerOverlay?.markNeedsBuild();
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

    Overlay.of(context).insert(_timePickerOverlay!);
  }

  void _removeTimePickerOverlay() {
    _timePickerOverlay?.remove();
    _timePickerOverlay = null;
  }

  bool _hasPrefilledEdit = false;

  /// True when editing an existing child game (event_from 1 or 2 = linked to a parent league/tournament).
  /// Used to auto-hide scheduling type and event type sections — values are derived from the event itself.
  bool get _isChildGameEdit {
    if (widget.isDuplicate || widget.editEvent == null) return false;
    final ef = widget.editEvent!.eventFrom;
    return ef == 1 || ef == 2;
  }

  /// True when duplicating a child game (event_from 1 or 2).
  /// Same hiding behaviour as _isChildGameEdit and the Add Game button.
  bool get _isChildDuplicate {
    if (!widget.isDuplicate || widget.editEvent == null) return false;
    final ef = widget.editEvent!.eventFrom;
    return ef == 1 || ef == 2;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.defaultSchedulingTypeKey != null) _schedulingTypeKey = widget.defaultSchedulingTypeKey!;
    if (widget.defaultEventTypeKey != null) _eventTypeKey = widget.defaultEventTypeKey!;

    _selectedDate ??= DateUtils.dateOnly(DateTime.now());
    _selectedMonth = DateTime(_selectedDate!.year, _selectedDate!.month, 1);
    _selectedMonthlyDates = {DateUtils.dateOnly(_selectedDate!)};

    final defaultEnd = _computeEndTime(_startTime, _durationHours, _durationMinutes);
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    _weeklySlots = List.generate(7, (i) {
      return WeeklySlotConfig(
        dayName: dayNames[i],
        weekday: i + 1,
        isChecked: true, // Checked by default matching web UI
        startTime: _startTime,
        endTime: defaultEnd,
      );
    });

    // Always re-fetch dropdowns on every open so data is fresh
    Future.microtask(() {
      ref.read(eventAddEditProvider.notifier).fetchNewEventDropdowns();
      final activeTeam = ref.read(selectedTeamProvider);
      if (activeTeam != null) {
        _rosterNotifier = ref.read(rosterProvider.notifier);
        _rosterNotifier!.fetchPlayers(activeTeam.uuid, staffType: 'team');
      }
    });
  }

  /// Pre-fills all form fields from [widget.editEvent] after dropdowns have loaded.
  /// Called once from [build] when dropdowns are available and edit mode is active.
  void _prefillFromEvent(NewEventDropdownOptions dropdowns) {
    if (widget.editEvent == null || _hasPrefilledEdit) return;
    final e = widget.editEvent!;
    setState(() {
      _hasPrefilledEdit = true;
      _isCancelled = !widget.isDuplicate && e.status == 2;

      // Scheduling / event type
      _schedulingTypeKey = e.schedulingMode;
      _eventTypeKey = e.eventTypeKey;
      _homeAwayKey = e.homeAwayKey > 0
          ? e.homeAwayKey
          : (dropdowns.homeAwayOptions.isNotEmpty ? 1 : 0);
      _arrivalTimeKey = e.arrivalEarly;

      // Date & time (dateTime already parsed by home/schedule service)
      _selectedDate = DateUtils.dateOnly(e.dateTime);
      _startTime = TimeOfDay(hour: e.dateTime.hour, minute: e.dateTime.minute);

      // Duration
      _durationHours = e.duration.inHours;
      _durationMinutes = e.duration.inMinutes.remainder(60);

      // Location
      final loc = e.location.trim();
      if (loc.isEmpty || loc.toLowerCase() == 'tbd') {
        _locationMode = EventLocationMode.tbd;
        _locationController.clear();
        _locationName = '';
        _selectedVenue = null;
        _selectedFieldItem = null;
        _selectedSavedLocationItem = null;
      } else {
        // 1. Try matching with our locations from API
        OurLocationVenue? matchingVenue;
        OurLocationField? matchingField;

        for (final v in dropdowns.ourLocations) {
          if (loc.toLowerCase().startsWith(v.name.toLowerCase()) ||
              loc.toLowerCase().startsWith(v.label.toLowerCase())) {
            matchingVenue = v;
            if (loc.contains(' - ')) {
              final locLower = loc.toLowerCase();
              final parts = loc.split(' - ');
              final fieldPart = parts.sublist(1).join(' - ').trim().toLowerCase();
              for (final fld in v.fields) {
                // Field names may or may not already include the facility name.
                if (locLower == _venueFieldName(v, fld).toLowerCase() ||
                    locLower == '${v.name} - ${fld.fieldName}'.toLowerCase() ||
                    fld.fieldName.toLowerCase() == fieldPart ||
                    fld.label.toLowerCase() == fieldPart) {
                  matchingField = fld;
                  break;
                }
              }
            }
            break;
          }
        }

        // 2. Try matching with saved locations from API
        SavedLocationItem? matchingSaved;
        if (matchingVenue == null) {
          for (final s in dropdowns.savedLocations) {
            if (s.name.toLowerCase() == loc.toLowerCase() ||
                s.location.toLowerCase() == loc.toLowerCase() ||
                (s.address.isNotEmpty && s.address.toLowerCase() == loc.toLowerCase())) {
              matchingSaved = s;
              break;
            }
          }
        }

        if (matchingVenue != null) {
          _locationMode = EventLocationMode.ourLocations;
          _selectedVenue = matchingVenue;
          _selectedFieldItem = matchingField;
          _latitude = matchingVenue.latitude;
          _longitude = matchingVenue.longitude;
        } else if (matchingSaved != null) {
          _locationMode = EventLocationMode.savedLocation;
          _selectedSavedLocationItem = matchingSaved;
          _latitude = matchingSaved.latitude;
          _longitude = matchingSaved.longitude;
          _address = matchingSaved.address;
          _city = matchingSaved.city;
          _state = matchingSaved.state;
          _country = matchingSaved.country;
          _postalCode = matchingSaved.postalCode;
          _placeId = matchingSaved.placeId;
        } else {
          _locationMode = EventLocationMode.offSiteAddress;
          _locationController.text = loc;
          _locationName = loc;
          _address = loc;
          _latitude = e.latitude ?? '';
          _longitude = e.longitude ?? '';
        }
      }

      // Title (pre-fill with original event title)
      _titleController.text = _originalEventTitle;

      // Notes
      _notesController.text = e.notes ?? '';

      // Tournament/League — always default to placeholder on edit
      _knowsSchedule = false;
      _startDate = e.startDate;
      _endDate = e.endDate;

      // Opponent
      if (e.opponentTeamId > 0) {
        final inList = dropdowns.teams.any((t) => t.id == e.opponentTeamId);
        if (inList) {
          _selectedOpponentId = e.opponentTeamId.toString();
        } else {
          // Team not in dropdown list — pre-fill as new opponent inline
          _newOpponentNameController.text = e.opponent ?? '';
          _selectedOpponentId = '__new__';
          _showAddOpponentInline = true;
        }
      } else if (e.opponent != null && e.opponent!.isNotEmpty) {
        _newOpponentNameController.text = e.opponent!;
        _selectedOpponentId = '__new__';
        _showAddOpponentInline = true;
      }

      // Uniform
      _uniformItems = dropdowns.uniformItems;
      if (e.uniformTemplateId > 0) {
        final template = dropdowns.uniformTemplates
            .where((t) => t.id == e.uniformTemplateId)
            .firstOrNull;
        if (template != null) {
          _selectedApiTemplate = template;
          _selectedUniformMode = template.templateName;
          _applyTemplateColors(template);
          if (template.topColor.isEmpty) _topColorIndex = hexToColorIndex(e.uniformTopColor);
          if (template.bottomColor.isEmpty) _bottomColorIndex = hexToColorIndex(e.uniformBottomColor);
          if (template.socksColor.isEmpty) _socksColorIndex = hexToColorIndex(e.uniformSocksColor);
        } else {
          // Template not in list — fall back to hex colors
          _topColorIndex = hexToColorIndex(e.uniformTopColor);
          _bottomColorIndex = hexToColorIndex(e.uniformBottomColor);
          _socksColorIndex = hexToColorIndex(e.uniformSocksColor);
          _selectedUniformMode = 'New combo';
        }
      } else if (e.uniformTopColor.isNotEmpty || e.uniformBottomColor.isNotEmpty || e.uniformSocksColor.isNotEmpty) {
        _topColorIndex = hexToColorIndex(e.uniformTopColor);
        _bottomColorIndex = hexToColorIndex(e.uniformBottomColor);
        _socksColorIndex = hexToColorIndex(e.uniformSocksColor);
        _selectedUniformMode = 'New combo';
      }
    });
  }

  // Event page loads team-only staff into the shared roster state; restore the
  // default (all staff) list when leaving so the Roster tab isn't affected.
  RosterNotifier? _rosterNotifier;

  @override
  void dispose() {
    final rosterNotifier = _rosterNotifier;
    if (rosterNotifier != null) {
      Future.microtask(() => rosterNotifier.refresh(staffType: null));
    }
    WidgetsBinding.instance.removeObserver(this);
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

  TimeOfDay _computeEndTime(TimeOfDay start, int durHours, int durMinutes) {
    final startMinutes = start.hour * 60 + start.minute;
    final durationMinutes = durHours * 60 + durMinutes;
    final totalMinutes = startMinutes + durationMinutes;

    final endHour = (totalMinutes ~/ 60) % 24;
    final endMinute = totalMinutes % 60;
    return TimeOfDay(hour: endHour, minute: endMinute);
  }

  void _syncWeeklySlotTimes() {
    final end = _computeEndTime(_startTime, _durationHours, _durationMinutes);
    for (final slot in _weeklySlots) {
      slot.startTime = _startTime;
      slot.endTime = end;
    }
  }

  String _formatDateMMDDYYYY(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$m/$d/$y';
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    final colors = AppColors.current;
    if (!isRequired) {
      return Text(
        label,
        style: AppTextStyles.heading14.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      );
    }
    return RichText(
      text: TextSpan(
        text: label,
        style: AppTextStyles.heading14.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Dynamic End Time computation based on Start Time + Duration
  String _getEndTimeString() {
    final end = _computeEndTime(_startTime, _durationHours, _durationMinutes);
    final amPm = end.hour >= 12 ? 'PM' : 'AM';
    final displayHour = end.hour == 0 ? 12 : (end.hour > 12 ? end.hour - 12 : end.hour);
    final displayMinuteStr = end.minute.toString().padLeft(2, '0');

    return 'Ends at $displayHour:$displayMinuteStr $amPm';
  }

  // ── Time helpers ─────────────────────────────────────────────────────────────

  bool _isToday() {
    if (_selectedDate == null) return false;
    return DateUtils.dateOnly(_selectedDate!) == DateUtils.dateOnly(DateTime.now());
  }

  /// Clamps _startTime to now+1 min if today is selected. Pure mutation — call inside setState.
  void _clampStartTimeToNowIfToday() {
    if (!_isToday()) return;
    final now = DateTime.now();
    final minAllowed = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    final selected = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime.hour,
      _startTime.minute,
    );
    if (selected.isBefore(minAllowed)) {
      _startTime = TimeOfDay(hour: minAllowed.hour, minute: minAllowed.minute);
    }
  }

  // Pickers
  Future<void> _pickDate(BuildContext context) async {
    _closeAllDropdowns(unfocus: true);
    final today = DateUtils.dateOnly(DateTime.now());
    final parent = widget.parentEvent;

    // Default bounds
    DateTime firstDate = today;
    DateTime lastDate = DateTime(2100, 12, 31);

    // If a parent league/tournament is provided, restrict to its date range
    if (parent != null) {
      if (parent.startDate != null) {
        final parentStart = DateUtils.dateOnly(parent.startDate!);
        firstDate = parentStart.isAfter(today) ? parentStart : today;
      }
      if (parent.endDate != null) {
        lastDate = DateUtils.dateOnly(parent.endDate!);
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedMonth = DateTime(picked.year, picked.month, 1);
        _selectedMonthlyDates = {DateUtils.dateOnly(picked)};
        _clampStartTimeToNowIfToday();
      });
    }
  }

  Future<void> _pickStartDate(BuildContext context) async {
    _closeAllDropdowns(unfocus: true);
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100, 12, 31),
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
    _closeAllDropdowns(unfocus: true);
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }


  // ── Helpers ──────────────────────────────────────────────────────────────────

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
      topColor: uniformColorToHex(kUniformColors[_topColorIndex]),
      bottomColor: uniformColorToHex(kUniformColors[_bottomColorIndex]),
      socksColor: uniformColorToHex(kUniformColors[_socksColorIndex]),
      chooseCombo: _showSaveTemplateForm && _templateNameController.text.trim().isNotEmpty,
      templateName: _showSaveTemplateForm ? _templateNameController.text.trim() : '',
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

  Future<void> _handleDeleteEvent() async {
    final colors = AppColors.current;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.background,
        title: Text('Delete Event', style: AppTextStyles.heading18.copyWith(color: colors.textPrimary)),
        content: Text(
          'Are you sure you want to permanently delete this event?',
          style: AppTextStyles.body16.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await ref.read(eventAddEditProvider.notifier).deleteEvent(
      widget.editEvent?.dbId,
      schedulingMode: widget.editEvent?.schedulingMode ?? 1,
    );

    if (!mounted) return;
    if (success) {
      ref.read(eventRefreshSignalProvider.notifier).signal();
      final destination = widget.origin == 'schedule' ? AppRoutes.schedule : AppRoutes.home;
      context.go(destination);
    } else {
      final errMsg = ref.read(eventAddEditProvider).saveError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errMsg?.isNotEmpty == true ? errMsg! : 'Failed to delete event'),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleSaveResult(bool success) {
    if (!mounted) return;
    if (success) {
      ref.read(eventRefreshSignalProvider.notifier).signal();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Event saved - families will be notified'),
          backgroundColor: AppColors.current.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      final destination = widget.origin == 'schedule' ? AppRoutes.schedule : AppRoutes.home;
      context.go(destination);
    } else {
      _showErrorDialog(
        ref.read(eventAddEditProvider).newEventSaveError ?? 'Failed to create event',
      );
    }
  }

  /// Returns the original event title for comparison and fallback pre-fill.
  String get _originalEventTitle => DuplicateEventHelper.getOriginalEventTitle(widget.editEvent);

  /// Checks whether all relevant event details of the duplicated event are
  /// 100% identical to the original event [widget.editEvent].
  bool _isDuplicatedEventIdentical() {
    final e = widget.editEvent;
    if (e == null) return false;
    return DuplicateEventHelper.isDuplicatedEventIdentical(
      originalEvent: e,
      schedulingTypeKey: _schedulingTypeKey,
      eventTypeKey: _eventTypeKey,
      location: _resolveLocationText() ?? (_locationName.isNotEmpty ? _locationName : _locationController.text),
      notes: _notesController.text,
      isCancelled: _isCancelled,
      selectedDate: _selectedDate,
      startTime: _startTime,
      durationMinutes: _durationHours * 60 + _durationMinutes,
      homeAwayKey: _homeAwayKey,
      arrivalTimeKey: _arrivalTimeKey,
      selectedOpponentId: _selectedOpponentId,
      newOpponentName: _newOpponentNameController.text,
      title: _titleController.text,
      selectedApiTemplate: _selectedApiTemplate,
      topColorIndex: _topColorIndex,
      bottomColorIndex: _bottomColorIndex,
      socksColorIndex: _socksColorIndex,
      showSaveTemplateForm: _showSaveTemplateForm,
      templateName: _templateNameController.text,
      knowsSchedule: _knowsSchedule,
      startDate: _startDate,
      endDate: _endDate,
      latitude: _latitude,
      longitude: _longitude,
    );
  }

  void _onSave() => _doSave();

  Future<void> _doSave() async {
    if (ref.read(eventAddEditProvider).isSavingNewEvent) return;

    // The "everyone invited" default is normally set when the RSVP tab is built.
    // If the user never opened it, apply the same default so invitees aren't lost.
    if (!_hasInitializedRsvpSelection) {
      final members = ref.read(rosterProvider).allMembers;
      final athletes = members.where((m) => m.role == MemberRole.player);
      final staff = members.where((m) => m.role == MemberRole.staff);
      if (athletes.isNotEmpty || staff.isNotEmpty) {
        _selectedAthleteIds = athletes.map((a) => a.apiId).toSet();
        _selectedStaffIds = staff.map((s) => s.apiId).toSet();
        _hasInitializedRsvpSelection = true;
      }
    }

    // Uniform template name validation — if toggle is shown, name is required and must be alphanumeric
    if (_selectedApiTemplate == null && _showSaveTemplateForm) {
      final name = _templateNameController.text.trim();
      if (name.isEmpty) {
        _showError('Please enter a template name or hide the template form');
        return;
      }
      if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(name)) {
        _showError('Template name must contain only letters, numbers, and spaces');
        return;
      }
    }

    // Edit-mode values ('' for create/duplicate mode)
    final editId = (!widget.isDuplicate) ? (widget.editEvent?.dbId?.toString() ?? '') : '';
    final existingSchedulingMode = (!widget.isDuplicate) ? (widget.editEvent?.existingSchedulingMode ?? '') : '';
    final editStatus = widget.isDuplicate ? 1 : (widget.editEvent != null ? (_isCancelled ? 2 : 1) : '');

    // ── Flow 1: Single Session ─────────────────────────────────────────────
    if (_schedulingTypeKey == 1) {
      if (_selectedDate == null) {
        setState(() => _selectedTabIndex = 0);
        _showError('Please select a date');
        return;
      }

      if (_isRepeating) {
        if (_repeatType == 'Weekly') {
          if (_repeatUntilDate == null) {
            setState(() => _selectedTabIndex = 0);
            _showError('Please select a repeat until date');
            return;
          }
          if (!_weeklySlots.any((s) => s.isChecked)) {
            setState(() => _selectedTabIndex = 0);
            _showError('Please select at least one day for weekly repeat');
            return;
          }
        } else if (_repeatType == 'Monthly') {
          if (_selectedMonthlyDates.isEmpty) {
            setState(() => _selectedTabIndex = 0);
            _showError('Please select at least one date for monthly repeat');
            return;
          }
        }
      }

      final locationText = _resolveLocationText();
      if (locationText == null) {
        setState(() => _selectedTabIndex = 1);
        if (_locationMode == EventLocationMode.ourLocations) {
          _showError('Please select a facility');
        } else if (_locationMode == EventLocationMode.savedLocation) {
          _showError('Please select a saved location');
        } else if (_locationMode == EventLocationMode.offSiteAddress) {
          _showError('Please enter an address');
        } else {
          _showError('Please set a location');
        }
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
        if (_selectedOpponentId == '__new__') {
          opponentTeamName = _newOpponentNameController.text.trim();
          if (opponentTeamName.isEmpty) {
            _showError('Please enter opponent name');
            return;
          }
          allowForFutureGames = _saveOpponentForFuture;
        } else if (_selectedOpponentId.isNotEmpty) {
          // Existing team selected from API list — send ID only
          opponentTeamId = _selectedOpponentId;
          allowForFutureGames = false;
        } else {
          _showError('Please select or add an opponent');
          return;
        }

        // Duplicate naming logic for game/scrimmage
        if (widget.isDuplicate && _isDuplicatedEventIdentical()) {
          final origTitle = _originalEventTitle;
          title = origTitle.isNotEmpty ? 'Copy of - $origTitle' : 'Copy of - Event';
        }
      } else {
        // Flow 2: Practice, Team Event, Camp — title is required, no opponent
        title = _titleController.text.trim();
        if (title.isEmpty) {
          _showError('Please enter a title');
          return;
        }
        if (!RegExp(r'[a-zA-Z]').hasMatch(title)) {
          _showError('Title must contain at least one letter');
          return;
        }

        // Duplicate naming logic: prepend "Copy of - " only if 100% identical to original
        if (widget.isDuplicate && _isDuplicatedEventIdentical()) {
          title = 'Copy of - $title';
          _titleController.text = title;
        }
        allowForFutureGames = false;
      }

      final activeTeam = ref.read(selectedTeamProvider);
      if (activeTeam == null) {
        _showError('No active team selected');
        return;
      }

      final locData = _extractLocationData();
      final totalDurationMinutes = _durationHours * 60 + _durationMinutes;
      final startDateTime = DateTime(2000, 1, 1, _startTime.hour, _startTime.minute);
      final endDateTime = startDateTime.add(Duration(minutes: totalDurationMinutes));
      final endTimeStr = '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';

      int recurringType = 1;
      dynamic recurrenceDays;
      String? sessionEndDate;

      if (_isRepeating) {
        if (_repeatType.toLowerCase() == 'weekly') {
          recurringType = 2;
          sessionEndDate = _repeatUntilDate != null ? _formatSessionDate(_repeatUntilDate!) : null;
          recurrenceDays = _weeklySlots.where((s) => s.isChecked).map((s) {
            final slotStart = _formatStartTime24(s.startTime);
            final slotEnd = _formatStartTime24(s.endTime);
            final dayMap = <String, dynamic>{
              'day': s.dayName,
              'start_time': slotStart,
            };
            if (slotEnd.isNotEmpty) {
              dayMap['end_time'] = slotEnd;
            }
            return dayMap;
          }).toList();
        } else if (_repeatType.toLowerCase() == 'monthly') {
          recurringType = 3;
          final sortedDates = _selectedMonthlyDates.toList()..sort();
          recurrenceDays = sortedDates.map(_formatSessionDate).toList();
        }
      }

      final playerIds = _selectedAthleteIds
          .map((id) => int.tryParse(id))
          .whereType<int>()
          .toList();
      final staffIds = _selectedStaffIds
          .map((id) => int.tryParse(id))
          .whereType<int>()
          .toList();

      final uniformFields = _buildUniformFields();
      final uniformMap = _buildUniformMap(uniformFields.templateId);

      final request = NewEventSaveRequest(
        teamUuid: activeTeam.uuid,
        organizationId: activeTeam.organizationId,
        organizationName: activeTeam.organizationName,
        teamId: activeTeam.teamId,
        teamName: activeTeam.name,
        createdFrom: 1,
        withCalendarRows: 1,
        id: editId,
        existingSchedulingMode: existingSchedulingMode,
        status: editStatus,
        schedulingMode: _schedulingTypeKey,
        eventType: _eventTypeKey,
        eventFrom: widget.parentEvent != null ? 2 : (widget.editEvent?.eventFrom ?? 0),
        eventId: widget.parentEvent?.dbId ?? (widget.editEvent?.eventId ?? 0),
        scheduleGameId: widget.editEvent?.scheduleGameId ?? 0,
        title: title,
        sessionStartDate: _formatSessionDate(_selectedDate!),
        sessionEndDate: sessionEndDate,
        startTime: _formatStartTime24(_startTime),
        endTime: endTimeStr,
        duration: totalDurationMinutes,
        recurringType: recurringType,
        days: recurrenceDays,
        homeAway: _homeAwayKey,
        arrivalEarly: _arrivalTimeKey,
        locationType: locData.locationType,
        venueId: locData.venueId,
        fieldId: locData.fieldId,
        savedLocationId: locData.savedLocationId,
        location: locData.locationName.isNotEmpty ? locData.locationName : locationText,
        address: locData.address,
        city: locData.city,
        state: locData.state,
        country: locData.country,
        postalCode: locData.postalCode,
        placeId: locData.placeId,
        latitude: locData.latitude,
        longitude: locData.longitude,
        opponentTeamId: opponentTeamId,
        opponentTeamName: opponentTeamName,
        allowForFutureGames: allowForFutureGames,
        uniformTemplateId: uniformFields.templateId,
        uniform: uniformMap,
        uniformTopColor: uniformFields.topColor,
        uniformBottomColor: uniformFields.bottomColor,
        uniformSocksColor: uniformFields.socksColor,
        chooseComboAsTemplate: uniformFields.chooseCombo,
        uniformTemplateName: uniformFields.templateName,
        notes: _notesController.text,
        isRepeating: _isRepeating,
        repeatType: _repeatType,
        repeatUntil: _repeatUntilDate != null ? _formatSessionDate(_repeatUntilDate!) : '',
        playerIds: playerIds,
        staffIds: staffIds,
      );

      final success = await ref.read(eventAddEditProvider.notifier).saveNewEvent(request);
      _handleSaveResult(success);
      return;
    }

    // ── Flows 3 & 4: Tournament / League ──────────────────────────────────
    if (_schedulingTypeKey == 2 || _schedulingTypeKey == 3) {
      // Tournament and League use the same location types as single session.
      String? multiDayLocation() {
        final t = _resolveLocationText();
        if (t == null) {
          _showError(switch (_locationMode) {
            EventLocationMode.ourLocations => 'Please select a facility',
            EventLocationMode.savedLocation => 'Please select a saved location',
            EventLocationMode.offSiteAddress => 'Please enter an address',
            EventLocationMode.tbd => 'Please set a location',
          });
        }
        return t;
      }
      final locData = _extractLocationData();

      if (!_knowsSchedule) {
        // Flow 3: Placeholder — date range only
        var title = _titleController.text.trim();
        if (title.isEmpty) {
          _showError('Please enter a title');
          return;
        }
        if (!RegExp(r'[a-zA-Z]').hasMatch(title)) {
          _showError('Title must contain at least one letter');
          return;
        }

        // Duplicate naming logic: prepend "Copy of - " only if 100% identical to original
        if (widget.isDuplicate && _isDuplicatedEventIdentical()) {
          title = 'Copy of - $title';
          _titleController.text = title;
        }
        if (_startDate == null) {
          _showError('Please select a start date');
          return;
        }
        if (_endDate == null) {
          _showError('Please select an end date');
          return;
        }
        final locationText = multiDayLocation();
        if (locationText == null) return;

        final activeTeam = ref.read(selectedTeamProvider);
        if (activeTeam == null) {
          _showError('No active team selected');
          return;
        }

        final playerIds = _selectedAthleteIds
            .map((id) => int.tryParse(id))
            .whereType<int>()
            .toList();
        final staffIds = _selectedStaffIds
            .map((id) => int.tryParse(id))
            .whereType<int>()
            .toList();

        final request = NewEventSaveRequest(
          teamUuid: activeTeam.uuid,
          organizationId: activeTeam.organizationId,
          organizationName: activeTeam.organizationName,
          teamId: activeTeam.teamId,
          teamName: activeTeam.name,
          createdFrom: 1,
          withCalendarRows: 1,
          id: editId,
          existingSchedulingMode: existingSchedulingMode,
          status: editStatus,
          schedulingMode: _schedulingTypeKey,
          eventType: 0,
          eventFrom: widget.parentEvent != null ? 2 : (_isChildGameEdit ? 2 : 0),
          eventId: widget.parentEvent?.dbId ?? 0,
          scheduleGameId: widget.editEvent?.scheduleGameId ?? 0,
          title: title,
          sessionDate: '',
          startTime: '',
          duration: 0,
          homeAway: 0,
          arrivalEarly: 0,
          locationType: locData.locationType,
          venueId: locData.venueId,
          fieldId: locData.fieldId,
          savedLocationId: locData.savedLocationId,
          location: (locData.locationName.isNotEmpty ? locData.locationName : locationText),
          address: locData.address,
          city: locData.city,
          state: locData.state,
          country: locData.country,
          postalCode: locData.postalCode,
          placeId: locData.placeId,
          latitude: locData.latitude,
          longitude: locData.longitude,
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
          playerIds: playerIds,
          staffIds: staffIds,
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
      final locationText = multiDayLocation();
      if (locationText == null) return;

      final activeTeam = ref.read(selectedTeamProvider);
      if (activeTeam == null) {
        _showError('No active team selected');
        return;
      }

      // Flow 4: "Yes I have it" → same opponent logic as flow 1
      String flow4OpponentTeamId = '';
      String flow4OpponentTeamName = '';
      bool flow4AllowForFutureGames = false;

      if (_selectedOpponentId == '__new__') {
        flow4OpponentTeamName = _newOpponentNameController.text.trim();
        if (flow4OpponentTeamName.isEmpty) {
          _showError('Please enter opponent name');
          return;
        }
        flow4AllowForFutureGames = _saveOpponentForFuture;
      } else if (_selectedOpponentId.isNotEmpty) {
        flow4OpponentTeamId = _selectedOpponentId;
        flow4AllowForFutureGames = false;
      } else {
        _showError('Please select or add an opponent');
        return;
      }

      var flow4Title = '';
      if (widget.isDuplicate && _isDuplicatedEventIdentical()) {
        final origTitle = _originalEventTitle;
        flow4Title = origTitle.isNotEmpty ? 'Copy of - $origTitle' : 'Copy of - Event';
      }

      final totalDurationMinutes = _durationHours * 60 + _durationMinutes;
      final startDateTime = DateTime(2000, 1, 1, _startTime.hour, _startTime.minute);
      final endDateTime = startDateTime.add(Duration(minutes: totalDurationMinutes));
      final endTimeStr = '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';

      final playerIds = _selectedAthleteIds
          .map((id) => int.tryParse(id))
          .whereType<int>()
          .toList();
      final staffIds = _selectedStaffIds
          .map((id) => int.tryParse(id))
          .whereType<int>()
          .toList();

      final uniformFields = _buildUniformFields();
      final uniformMap = _buildUniformMap(uniformFields.templateId);

      // Flow 4: "Yes I have it" → always sent as single session game (scheduling_mode=1, event_type=1)
      final request = NewEventSaveRequest(
        teamUuid: activeTeam.uuid,
        organizationId: activeTeam.organizationId,
        organizationName: activeTeam.organizationName,
        teamId: activeTeam.teamId,
        teamName: activeTeam.name,
        createdFrom: 1,
        withCalendarRows: 1,
        id: editId,
        existingSchedulingMode: existingSchedulingMode,
        status: editStatus,
        schedulingMode: 1,
        eventType: 1,
        eventFrom: widget.parentEvent != null ? 2 : (widget.editEvent?.eventFrom ?? 0),
        eventId: widget.parentEvent?.dbId ?? (widget.editEvent?.eventId ?? 0),
        scheduleGameId: widget.editEvent?.scheduleGameId ?? 0,
        title: flow4Title,
        sessionStartDate: _formatSessionDate(_selectedDate!),
        startTime: _formatStartTime24(_startTime),
        endTime: endTimeStr,
        duration: totalDurationMinutes,
        homeAway: _homeAwayKey,
        arrivalEarly: _arrivalTimeKey,
        locationType: locData.locationType,
        venueId: locData.venueId,
        fieldId: locData.fieldId,
        savedLocationId: locData.savedLocationId,
        location: (locData.locationName.isNotEmpty ? locData.locationName : locationText),
        address: locData.address,
        city: locData.city,
        state: locData.state,
        country: locData.country,
        postalCode: locData.postalCode,
        placeId: locData.placeId,
        latitude: locData.latitude,
        longitude: locData.longitude,
        opponentTeamId: flow4OpponentTeamId,
        opponentTeamName: flow4OpponentTeamName,
        allowForFutureGames: flow4AllowForFutureGames,
        uniformTemplateId: uniformFields.templateId,
        uniform: uniformMap,
        uniformTopColor: uniformFields.topColor,
        uniformBottomColor: uniformFields.bottomColor,
        uniformSocksColor: uniformFields.socksColor,
        chooseComboAsTemplate: uniformFields.chooseCombo,
        uniformTemplateName: uniformFields.templateName,
        notes: _notesController.text,
        playerIds: playerIds,
        staffIds: staffIds,
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
    final isEditMode = widget.editEvent != null && !widget.isDuplicate;
    final isDuplicateMode = widget.editEvent != null && widget.isDuplicate;

    // Pre-fill once dropdowns are ready in edit or duplicate mode
    if ((isEditMode || isDuplicateMode) && dropdownState.newEventDropdowns != null && !_hasPrefilledEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prefillFromEvent(dropdownState.newEventDropdowns!);
      });
    }

    // Create mode: default homeAwayKey to 1 (Home) once options load, but only if options exist
    if (!isEditMode && !isDuplicateMode && dropdownState.newEventDropdowns != null && _homeAwayKey == 0) {
      final opts = dropdownState.newEventDropdowns!.homeAwayOptions;
      if (opts.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _homeAwayKey == 0) setState(() => _homeAwayKey = 1);
        });
      }
    }

    final subHeader = SubHeader(
      title: isDuplicateMode ? 'Duplicate Event' : isEditMode ? 'Edit Event' : (widget.title ?? 'New Event'),
      leftIcon: Icons.close,
      leftLabel: 'Close',
      onLeftTap: () {
        _closeAllDropdowns(unfocus: true);
        context.pop();
      },
      rightWidget: dropdownState.isSavingNewEvent
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : null,
      rightText: 'Save',
      onRightTap: (dropdownState.isLoadingNewEventDropdowns || dropdownState.isSavingNewEvent)
          ? null
          : () {
              _closeAllDropdowns(unfocus: true);
              _onSave();
            },
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

    final showCategoryHeader = widget.defaultSchedulingTypeKey == null && !_isChildGameEdit && !_isChildDuplicate;

    return Scaffold(
      backgroundColor: colors.isDark ? colors.background : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildWebHeader(context),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _closeAllDropdowns(unfocus: true),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    if (showCategoryHeader) ...[
                      _buildCategoryHeaderCard(dropdowns),
                      const SizedBox(height: 16),
                    ],
                    if (_schedulingTypeKey == 1) ...[
                      _buildWebTabBar(),
                      const SizedBox(height: 16),
                      if (_selectedTabIndex == 0)
                        _buildDetailsTabContent(dropdowns)
                      else if (_selectedTabIndex == 1)
                        _buildLocationTabContent(dropdowns)
                      else if (_selectedTabIndex == 2)
                        _buildUniformTabContent(dropdowns)
                      else
                        _buildRsvpTabContent(dropdowns),
                    ] else if (_schedulingTypeKey == 2) ...[
                      _buildTournamentCard(dropdowns),
                      if (_knowsSchedule) ...[
                        const SizedBox(height: 16),
                        _buildWebTabBar(),
                        const SizedBox(height: 16),
                        if (_selectedTabIndex == 0)
                          _buildDetailsTabContent(dropdowns)
                        else if (_selectedTabIndex == 1)
                          _buildLocationTabContent(dropdowns)
                        else if (_selectedTabIndex == 2)
                          _buildUniformTabContent(dropdowns)
                        else
                          _buildRsvpTabContent(dropdowns),
                      ],
                    ] else if (_schedulingTypeKey == 3) ...[
                      _buildLeagueCard(dropdowns),
                      if (_knowsSchedule) ...[
                        const SizedBox(height: 16),
                        _buildWebTabBar(),
                        const SizedBox(height: 16),
                        if (_selectedTabIndex == 0)
                          _buildDetailsTabContent(dropdowns)
                        else if (_selectedTabIndex == 1)
                          _buildLocationTabContent(dropdowns)
                        else if (_selectedTabIndex == 2)
                          _buildUniformTabContent(dropdowns)
                        else
                          _buildRsvpTabContent(dropdowns),
                      ],
                    ],
                    if (isEditMode && !isDuplicateMode) ...[
                      const SizedBox(height: 16),
                      EventEditDangerCard(
                        isEdit: true,
                        isCancelled: _isCancelled,
                        onCancelledChanged: (v) => setState(() => _isCancelled = v),
                        onDelete: _handleDeleteEvent,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
            _buildWebFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWebHeader(BuildContext context) {
    final colors = AppColors.current;
    final isDark = colors.isDark;
    final isDuplicateMode = widget.editEvent != null && widget.isDuplicate;
    final isEditMode = widget.editEvent != null && !widget.isDuplicate;
    final title = isDuplicateMode
        ? 'Duplicate Event'
        : isEditMode
            ? 'Edit Event'
            : (widget.title ?? 'Add Event');

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 8, top: 8, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1D20),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              size: 24,
            ),
            splashRadius: 20,
            onPressed: () {
              _closeAllDropdowns(unfocus: true);
              context.pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWebTabBar() {
    final colors = AppColors.current;
    final isDark = colors.isDark;
    const activeYellow = Color(0xFFF5BD1F);
    final borderColor = isDark ? colors.border : const Color(0xFFE5E7EB);

    final tabs = ['Details', 'Location', 'Uniform', 'RSVP'];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colors.card : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _closeAllDropdowns(unfocus: true);
                setState(() => _selectedTabIndex = index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF2A281E) : const Color(0xFFFEFCE8))
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? activeYellow : Colors.transparent,
                      width: 3.0,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : const Color(0xFF1A1D20))
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWebFooter(BuildContext context) {
    final colors = AppColors.current;
    final isDark = colors.isDark;
    final isSaving = ref.watch(eventAddEditProvider).isSavingNewEvent;
    const yellowBtn = Color(0xFFF5BD1F);

    final isEditMode = widget.editEvent != null && !widget.isDuplicate;
    final saveButtonLabel = isEditMode
        ? 'Update Event'
        : (_schedulingTypeKey == 1 ? 'Save & Send RSVP' : 'Save Event');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? colors.card : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? colors.border : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                _closeAllDropdowns(unfocus: true);
                context.pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: isSaving ? null : () {
                _closeAllDropdowns(unfocus: true);
                _onSave();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: yellowBtn,
                foregroundColor: const Color(0xFF1A1D20),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A1D20)),
                      ),
                    )
                  : Text(
                      saveButtonLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1D20),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTabContent(NewEventDropdownOptions dropdowns) {
    final colors = AppColors.current;
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: _buildLocationView(dropdowns),
    );
  }

  /// Shared "Where is this happening?" selector (single session, tournament, league).
  Widget _buildLocationView(NewEventDropdownOptions dropdowns) {
    return EventLocationTabView(
        selectedMode: _locationMode,
        onModeChanged: (mode) {
          _closeAllDropdowns(unfocus: true);
          setState(() {
            _locationMode = mode;
            if (mode == EventLocationMode.tbd) {
              _locationController.clear();
              _locationName = 'TBD';
              _latitude = '';
              _longitude = '';
            }
          });
        },
        ourLocationVenues: dropdowns.ourLocations,
        selectedVenue: _selectedVenue,
        onVenueChanged: (venue) {
          setState(() {
            _selectedVenue = venue;
            _selectedFieldItem = null;
            if (venue != null) {
              _latitude = venue.latitude;
              _longitude = venue.longitude;
            }
          });
        },
        selectedFieldItem: _selectedFieldItem,
        onFieldItemChanged: (field) {
          setState(() {
            _selectedFieldItem = field;
          });
        },
        savedLocationItems: dropdowns.savedLocations,
        selectedSavedLocationItem: _selectedSavedLocationItem,
        onSavedLocationItemChanged: (saved) {
          setState(() {
            _selectedSavedLocationItem = saved;
            if (saved != null) {
              _address = saved.address;
              _city = saved.city;
              _state = saved.state;
              _country = saved.country;
              _postalCode = saved.postalCode;
              _placeId = saved.placeId;
              _latitude = saved.latitude;
              _longitude = saved.longitude;
            }
          });
        },
        addressController: _locationController,
        onAddressChanged: _onLocationChanged,
        addressFieldKey: _locationFieldKey,
        addressLayerLink: _locationLayerLink,
        onClearAddress: () {
          setState(() {
            _locationController.clear();
            _locationName = '';
            _address = '';
            _city = '';
            _state = '';
            _country = '';
            _postalCode = '';
            _placeId = '';
            _latitude = '';
            _longitude = '';
          });
          _hideLocationOverlay();
        },
    );
  }

  Widget _buildCategoryHeaderCard(NewEventDropdownOptions dropdowns) {
    if (widget.defaultSchedulingTypeKey != null || _isChildGameEdit || _isChildDuplicate) {
      return const SizedBox.shrink();
    }

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
        ],
      ),
    );
  }

  Widget _buildDetailsTabContent(NewEventDropdownOptions dropdowns) {
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
      child: _buildSingleSessionForm(dropdowns),
    );
  }

  Widget _buildTournamentCard(NewEventDropdownOptions dropdowns) {
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
      child: _buildTournamentForm(dropdowns),
    );
  }

  Widget _buildLeagueCard(NewEventDropdownOptions dropdowns) {
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
      child: _buildLeagueForm(dropdowns),
    );
  }

  Widget _buildUniformTabContent(NewEventDropdownOptions dropdowns) {
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
          _buildUniformSectionHeader(),
          const SizedBox(height: 8),
          _buildUniformFormContent(dropdowns),
        ],
      ),
    );
  }

  Widget _buildRsvpTabContent(NewEventDropdownOptions dropdowns) {
    final colors = AppColors.current;
    final isDark = colors.isDark;
    final rosterState = ref.watch(rosterProvider);

    if (rosterState.isLoading) {
      return Container(
        height: 260,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? colors.card : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CircularProgressIndicator(color: colors.primary),
      );
    }

    final rosterMembers = rosterState.allMembers;
    final apiAthletes = rosterMembers.where((m) => m.role == MemberRole.player).toList();
    final apiStaff = rosterMembers.where((m) => m.role == MemberRole.staff).toList();

    if (!_hasInitializedRsvpSelection && (apiAthletes.isNotEmpty || apiStaff.isNotEmpty)) {
      _selectedAthleteIds = apiAthletes.map((a) => a.apiId).toSet();
      _selectedStaffIds = apiStaff.map((s) => s.apiId).toSet();
      _hasInitializedRsvpSelection = true;
    }

    final allAthletesSelected = _selectedAthleteIds.length == apiAthletes.length && apiAthletes.isNotEmpty;
    final allStaffSelected = _selectedStaffIds.length == apiStaff.length && apiStaff.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colors.card : Colors.white,
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
          // ── ATHLETES Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ATHLETES',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? colors.textSecondary : const Color(0xFF6B7280),
                ),
              ),
              if (apiAthletes.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (allAthletesSelected) {
                        _selectedAthleteIds.clear();
                      } else {
                        _selectedAthleteIds = apiAthletes.map((a) => a.apiId).toSet();
                      }
                    });
                  },
                  child: Text(
                    allAthletesSelected ? 'Clear All' : 'Select All',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── ATHLETES Cards Grid ──
          if (apiAthletes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No athletes found in team roster.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? colors.textSecondary : const Color(0xFF6B7280),
                ),
              ),
            )
          else
            _buildMemberCardsGrid(
              members: apiAthletes,
              selectedIds: _selectedAthleteIds,
              onToggle: (id) {
                setState(() {
                  if (_selectedAthleteIds.contains(id)) {
                    _selectedAthleteIds.remove(id);
                  } else {
                    _selectedAthleteIds.add(id);
                  }
                });
              },
            ),
          const SizedBox(height: 24),

          // ── STAFF Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STAFF',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark ? colors.textSecondary : const Color(0xFF6B7280),
                ),
              ),
              if (apiStaff.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (allStaffSelected) {
                        _selectedStaffIds.clear();
                      } else {
                        _selectedStaffIds = apiStaff.map((s) => s.apiId).toSet();
                      }
                    });
                  },
                  child: Text(
                    allStaffSelected ? 'Clear All' : 'Select All',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── STAFF Cards Grid ──
          if (apiStaff.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No staff members found in team roster.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? colors.textSecondary : const Color(0xFF6B7280),
                ),
              ),
            )
          else
            _buildMemberCardsGrid(
              members: apiStaff,
              selectedIds: _selectedStaffIds,
              onToggle: (id) {
                setState(() {
                  if (_selectedStaffIds.contains(id)) {
                    _selectedStaffIds.remove(id);
                  } else {
                    _selectedStaffIds.add(id);
                  }
                });
              },
            ),
          const SizedBox(height: 20),

          // ── Footer Note ──
          Text(
            'Everyone picked here is invited to every date of this event and answers the RSVP in the Playbook Club Management App.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: isDark ? colors.textSecondary : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCardsGrid({
    required List<RosterMember> members,
    required Set<String> selectedIds,
    required ValueChanged<String> onToggle,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: members.map((member) {
            final isSelected = selectedIds.contains(member.apiId);
            return SizedBox(
              width: cardWidth,
              child: _buildRsvpMemberCard(
                member: member,
                isSelected: isSelected,
                onTap: () => onToggle(member.apiId),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRsvpMemberCard({
    required RosterMember member,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = AppColors.current;
    final isDark = colors.isDark;
    const yellowAccent = Color(0xFFF5BD1F);
    const cardYellowBg = Color(0xFFFEF9C3);

    final initial = member.firstName.isNotEmpty
        ? member.firstName[0].toUpperCase()
        : (member.lastName.isNotEmpty ? member.lastName[0].toUpperCase() : '?');

    final name = member.fullName.replaceAll(' ', '');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF382F10) : cardYellowBg)
              : (isDark ? colors.card : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? yellowAccent : (isDark ? colors.border : const Color(0xFFE5E7EB)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: yellowAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDE9FE),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6D28D9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1D20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        onTap: () {
          _closeAllDropdowns(unfocus: true);
          setState(() {
            _schedulingTypeKey = key;
            if (key == 1) {
              _selectedTabIndex = 0;
              // Single Session → default to Practice if no event type set
              if (_eventTypeKey == 0) _eventTypeKey = 2;
            }
            // Tournament / League → reset event type to 0 (not applicable)
            if (key == 2 || key == 3) _eventTypeKey = 0;
          });
        },
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

  // ── Single Session Form ──
  Widget _buildSingleSessionForm(NewEventDropdownOptions dropdowns) {
    final colors = AppColors.current;
    final dateStr = _formatDateMMDDYYYY(_selectedDate ?? DateTime.now());
    final startHour = _startTime.hour == 0 ? 12 : (_startTime.hour > 12 ? _startTime.hour - 12 : _startTime.hour);
    final startMinuteStr = _startTime.minute.toString().padLeft(2, '0');
    final startAmPm = _startTime.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$startHour:$startMinuteStr $startAmPm';
    // Tournament/League with "Yes, I have it" reuses this form for a single game.
    final isMultiDayGame = _schedulingTypeKey != 1 && _knowsSchedule;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Type — hidden when event type is pre-set or editing a child game
        if (!isMultiDayGame && widget.defaultEventTypeKey == null && !_isChildGameEdit && !_isChildDuplicate) ...[
          _buildFieldLabel('Event type', isRequired: true),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: dropdowns.eventTypes.map((type) => _buildEventTypeChip(type)).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Opponent Team (for Game or Scrimmage) OR Title (for Practice, Team Event, Camp)
        if (isMultiDayGame || _eventTypeKey == 1 || _eventTypeKey == 3) ...[
          _buildOpponentSection(dropdowns),
        ] else ...[
          _buildTextField(
            label: 'Title',
            hintText: 'e.g. Practice',
            controller: _titleController,
            isRequired: true,
            onTap: () => _closeAllDropdowns(),
          ),
        ],
        const SizedBox(height: 20),

        // Date Field — only shown when event does NOT repeat
        // When repeating, Start Date and Repeat Until are configured in the repeat section below
        if (isMultiDayGame || !_isRepeating) ...[
          _buildPickerField(
            label: 'Date',
            isRequired: true,
            valueText: dateStr,
            isPlaceholder: false,
            icon: Icons.calendar_today_outlined,
            iconOnLeft: true,
            onTap: () => _pickDate(context),
          ),
          const SizedBox(height: 20),
        ],

        // Start Time * and Duration Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: _buildPickerField(
                fieldKey: _startTimeFieldKey,
                layerLink: _startTimeLayerLink,
                label: 'Start Time',
                isRequired: true,
                valueText: timeStr,
                isPlaceholder: false,
                icon: Icons.access_time,
                iconOnLeft: true,
                onTap: _showStartTimeOverlay,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Duration', isRequired: false),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField<int>(
                          value: _durationHours,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          items: const [0, 1, 2, 3, 4, 5, 6, 7, 8],
                          itemLabel: (v) => v == 1 ? '1 hr' : '$v hrs',
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _durationHours = val;
                                _syncWeeklySlotTimes();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDropdownField<int>(
                          value: _durationMinutes,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          items: const [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55],
                          itemLabel: (v) => '$v min',
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _durationMinutes = val;
                                _syncWeeklySlotTimes();
                              });
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
        const SizedBox(height: 6),
        Text(
          _getEndTimeString(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colors.isDark ? colors.textSecondary : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 20),

        // Home or away
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Home or away', isRequired: false),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildHomeOrAwayButton(const NewEventHomeAwayOption(key: 1, value: 'home', label: 'Home')),
                const SizedBox(width: 10),
                _buildHomeOrAwayButton(const NewEventHomeAwayOption(key: 2, value: 'away', label: 'Away')),
                const SizedBox(width: 10),
                _buildHomeOrAwayButton(const NewEventHomeAwayOption(key: 3, value: 'neutral', label: 'Neutral')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Arrive how early
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Arrive how early', isRequired: false),
            const SizedBox(height: 8),
            _buildDropdownField<int>(
              value: _arrivalTimeKey,
              items: dropdowns.arrivalTimeOptions.isNotEmpty
                  ? dropdowns.arrivalTimeOptions.map((o) => o.key).toList()
                  : const [0, 15, 30, 45, 60],
              itemLabel: (key) => dropdowns.arrivalTimeOptions
                  .firstWhere(
                    (o) => o.key == key,
                    orElse: () => const NewEventArrivalTimeOption(key: 0, label: 'No set arrival time'),
                  )
                  .label,
              onChanged: (val) {
                if (val != null) setState(() => _arrivalTimeKey = val);
              },
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Repeats Until section (Weekly & Monthly modes)
        if (!isMultiDayGame) EventRepeatsUntilSection(
          isRepeating: _isRepeating,
          onRepeatingChanged: (v) => setState(() => _isRepeating = v),
          repeatType: _repeatType,
          onRepeatTypeChanged: (v) => setState(() => _repeatType = v),
          startDate: _selectedDate ?? DateTime.now(),
          onStartDateChanged: (d) => setState(() {
            _selectedDate = d;
            _selectedMonth = DateTime(d.year, d.month, 1);
            _selectedMonthlyDates = {DateUtils.dateOnly(d)};
            if (_repeatUntilDate != null && _repeatUntilDate!.isBefore(d)) {
              _repeatUntilDate = null;
            }
          }),
          repeatUntilDate: _repeatUntilDate,
          onRepeatUntilDateChanged: (d) => setState(() => _repeatUntilDate = d),
          weeklySlots: _weeklySlots,
          onWeeklySlotsChanged: (slots) => setState(() => _weeklySlots = slots),
          selectedMonthlyDates: _selectedMonthlyDates,
          onMonthlyDatesChanged: (dates) => setState(() => _selectedMonthlyDates = dates),
          selectedMonth: _selectedMonth,
          onSelectedMonthChanged: (m) => setState(() => _selectedMonth = m),
          defaultStartTime: _startTime,
          defaultEndTime: _computeEndTime(_startTime, _durationHours, _durationMinutes),
        ),
        if (!isMultiDayGame) const SizedBox(height: 20),

        // Notes for families
        _buildTextField(
          label: 'Notes for families',
          hintText: 'Arrive 30 min early. Bring both jerseys',
          controller: _notesController,
          maxLines: 3,
          onTap: () => _closeAllDropdowns(),
        ),
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
  Widget _buildSharedMultiDayForm({
    required String titlePlaceholder,
    required NewEventDropdownOptions dropdowns,
  }) {
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

    if (_knowsSchedule) {
      // "Yes, I have it": only the question here; the rest of the UI is the
      // single-session tabs rendered below this card.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title for placeholder mode / Opponent for "Yes, I have it"
        if (!_knowsSchedule) ...[
          _buildTextField(
            label: 'Title',
            hintText: titlePlaceholder,
            controller: _titleController,
            onTap: () => _closeAllDropdowns(),
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
                child: _buildPickerField(
                  fieldKey: _startTimeFieldKey,
                  layerLink: _startTimeLayerLink,
                  label: 'Start time',
                  valueText: timeStr,
                  isPlaceholder: false,
                  icon: Icons.access_time,
                  onTap: _showStartTimeOverlay,
                ),
              ),
              const SizedBox(width: 8),
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
                            padding: const EdgeInsets.symmetric(horizontal: 6),
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
                            padding: const EdgeInsets.symmetric(horizontal: 6),
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

          if (dropdowns.homeAwayOptions.isNotEmpty) ...[
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
          ],

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

        // Location
        _buildLocationView(dropdowns),
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
          onTap: () => _closeAllDropdowns(),
        ),
      ],
    );
  }

  // ── Helper Widgets ──

  Widget _buildHomeOrAwayButton(NewEventHomeAwayOption option) {
    final colors = AppColors.current;
    final isSelected = _homeAwayKey == option.key;
    const yellowAccent = Color(0xFFF5BD1F);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _closeAllDropdowns(unfocus: true);
          setState(() => _homeAwayKey = option.key);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? yellowAccent
                : (colors.isDark ? colors.background : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? yellowAccent : (colors.isDark ? colors.border : const Color(0xFFD1D5DB)),
              width: 1.2,
            ),
          ),
          child: Text(
            option.label,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? const Color(0xFF1A1D20)
                  : (colors.isDark ? Colors.white : const Color(0xFF374151)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventTypeChip(NewEventType type) {
    final colors = AppColors.current;
    final isSelected = _eventTypeKey == type.key;
    const yellowAccent = Color(0xFFF5BD1F);

    return GestureDetector(
      onTap: () {
        _closeAllDropdowns(unfocus: true);
        setState(() => _eventTypeKey = type.key);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? yellowAccent
              : (colors.isDark ? colors.background : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? yellowAccent : (colors.isDark ? colors.border : const Color(0xFFD1D5DB)),
            width: 1.2,
          ),
        ),
        child: Text(
          type.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected
                ? const Color(0xFF1A1D20)
                : (colors.isDark ? Colors.white70 : const Color(0xFF374151)),
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
        onTap: () {
          _closeAllDropdowns(unfocus: true);
          setState(() {
            _knowsSchedule = activeValue;
            _selectedTabIndex = 0;
          });
        },
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
    LayerLink? layerLink,
    required String label,
    required String hintText,
    required TextEditingController controller,
    Widget? prefixIcon,
    Widget? suffixIcon,
    int maxLines = 1,
    bool isRequired = false,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
  }) {
    final colors = AppColors.current;
    Widget textField = TextField(
      key: fieldKey,
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      onTap: onTap,
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
    );

    if (layerLink != null) {
      textField = CompositedTransformTarget(
        link: layerLink,
        child: textField,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isRequired),
        const SizedBox(height: 8),
        textField,
      ],
    );
  }

  Widget _buildPickerField({
    Key? fieldKey,
    LayerLink? layerLink,
    required String label,
    required String valueText,
    required bool isPlaceholder,
    required IconData icon,
    required VoidCallback onTap,
    bool iconOnLeft = false,
    bool isRequired = false,
  }) {
    final colors = AppColors.current;
    Widget picker = InkWell(
      key: fieldKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: colors.isDark ? colors.background : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.isDark ? colors.border : const Color(0xFFD1D5DB)),
        ),
        child: Row(
          children: [
            if (iconOnLeft) ...[
              Icon(icon, color: colors.textSecondary, size: 19),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                valueText,
                style: AppTextStyles.body15.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isPlaceholder
                      ? colors.textSecondary.withValues(alpha: 0.5)
                      : (colors.isDark ? Colors.white : const Color(0xFF1A1D20)),
                ),
              ),
            ),
            if (!iconOnLeft)
              Icon(icon, color: colors.textSecondary, size: 20),
          ],
        ),
      ),
    );

    if (layerLink != null) {
      picker = CompositedTransformTarget(
        link: layerLink,
        child: picker,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isRequired),
        const SizedBox(height: 8),
        picker,
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
  }) {
    final colors = AppColors.current;
    return Container(
      height: 48,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colors.isDark ? colors.background : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          onTap: () => _closeAllDropdowns(unfocus: true),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                style: textStyle ?? AppTextStyles.body14.copyWith(color: colors.textPrimary),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (val) {
            _closeAllDropdowns(unfocus: true);
            onChanged(val);
          },
          icon: Icon(Icons.keyboard_arrow_down, color: colors.textSecondary, size: 18),
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
    final selectedColorName = kUniformColors[selectedIndex].name;

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
          children: List.generate(kUniformColors.length, (index) {
            final item = kUniformColors[index];
            final isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () {
                _closeAllDropdowns(unfocus: true);
                onColorSelected(index);
              },
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
    
    final Color topColor = _selectedApiTemplate != null
        ? (hexToColor(_selectedApiTemplate!.topColor) ?? kUniformColors[_topColorIndex].color)
        : kUniformColors[_topColorIndex].color;
    final Color bottomColor = _selectedApiTemplate != null
        ? (hexToColor(_selectedApiTemplate!.bottomColor) ?? kUniformColors[_bottomColorIndex].color)
        : kUniformColors[_bottomColorIndex].color;
    final Color socksColor = _selectedApiTemplate != null
        ? (hexToColor(_selectedApiTemplate!.socksColor) ?? kUniformColors[_socksColorIndex].color)
        : kUniformColors[_socksColorIndex].color;

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
    _uniformItems = dropdowns.uniformItems;
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
                    onTap: () {
                      _closeAllDropdowns(unfocus: true);
                      setState(() {
                        _selectedUniformMode = t.templateName;
                        _selectedApiTemplate = t;
                        _applyTemplateColors(t);
                        _showSaveTemplateForm = false;
                        _templateNameController.clear();
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                ],
                for (final t in _localTemplates) ...[
                  _buildUniformTemplateTab(
                    label: t.name,
                    isSelected: _selectedApiTemplate == null && _selectedUniformMode == t.name,
                    onTap: () {
                      _closeAllDropdowns(unfocus: true);
                      setState(() {
                        _selectedUniformMode = t.name;
                        _selectedApiTemplate = null;
                        _topColorIndex = t.topIndex;
                        _bottomColorIndex = t.bottomIndex;
                        _socksColorIndex = t.socksIndex;
                        _showSaveTemplateForm = false;
                        _templateNameController.clear();
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                ],
                _buildUniformTemplateTab(
                  label: 'New combo',
                  isSelected: isNewCombo,
                  onTap: () {
                    _closeAllDropdowns(unfocus: true);
                    setState(() {
                      _selectedUniformMode = 'New combo';
                      _selectedApiTemplate = null;
                    });
                  },
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
          for (int i = 0; i < _uniformItems.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            _buildUniformColorSelector(
              label: _uniformItems[i].toUpperCase(),
              selectedIndex: _uniformColorIdx[_uniformItems[i]] ?? 0,
              onColorSelected: (idx) =>
                  setState(() => _uniformColorIdx[_uniformItems[i]] = idx),
            ),
          ],
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              _closeAllDropdowns(unfocus: true);
              setState(() => _showSaveTemplateForm = !_showSaveTemplateForm);
            },
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
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
              ],
              onTap: () => _closeAllDropdowns(),
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
        _buildFieldLabel('Opponent Team', isRequired: false),
        const SizedBox(height: 8),
        _buildDropdownField<String>(
          value: _selectedOpponentId,
          items: [
            '',
            ...dropdowns.teams.map((t) => t.id.toString()),
            '__new__',
          ],
          itemLabel: (v) {
            if (v == '') return 'Select opponent...';
            if (v == '__new__') return '+ Add a new opponent...';
            final match = dropdowns.teams.where((t) => t.id.toString() == v).firstOrNull;
            return match?.name ?? v;
          },
          onChanged: (val) {
            if (val == '__new__') {
              setState(() {
                _showAddOpponentInline = true;
                _selectedOpponentId = '__new__';
              });
            } else if (val != null) {
              setState(() {
                _selectedOpponentId = val;
                _showAddOpponentInline = false;
                _newOpponentNameController.clear();
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
            onTap: () => _closeAllDropdowns(),
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
