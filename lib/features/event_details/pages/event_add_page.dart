import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/config/environment_config.dart';
import '../providers/event_add_edit_provider.dart';
import '../models/event_dropdown_options_models.dart';
import '../services/event_detail_service.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../../../core/shared_widgets/sub_header.dart';
import '../../../core/shared_widgets/textfield/app_text_field.dart';
import '../widgets/event_edit_danger_card.dart';
import '../widgets/event_edit_form_card.dart';
import '../widgets/event_edit_inline_field.dart';
import '../widgets/event_edit_list_row.dart';
import '../widgets/event_edit_notify_card.dart';
import '../widgets/event_edit_toggle_row.dart';
import '../../home/providers/home_provider.dart';
import '../../schedule/providers/schedule_provider.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../../../core/models/club_event.dart';


// ─── Add Event Page ──────────────────────────────────────────────────────────

class EventEditPage extends ConsumerStatefulWidget {
  final String eventId;
  final bool duplicate;
  final String from;

  const EventEditPage({
    super.key,
    required this.eventId,
    this.duplicate = false,
    this.from = 'home',
  });

  @override
  ConsumerState<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends ConsumerState<EventEditPage> {
  // Toggle states
  bool _notifyTeam = true;
  bool _timeTbd    = false;
  bool _trackAvail = true;
  bool _hasPrepopulatedTimezone = false;
  bool _isScheduledGame = false;
  bool _isCancelled = false;

  // Controllers
  final _eventNameController       = TextEditingController(text: '');
  final _locationDetailsController = TextEditingController(text: '');
  final _extraLabelController      = TextEditingController(text: '');
  final _notesController           = TextEditingController(text: '');
  final _uniformColorController    = TextEditingController(text: '');
  final _opponentController        = TextEditingController(text: '');
  
  final _timezoneSearchController  = TextEditingController();
  final _timezoneScrollController  = ScrollController();

  // Advanced state pickers
  DateTime? _selectedDateTime;
  int _durationMinutes             = 60;
  int _arrivalEarlyMinutes         = 15;
  String _locationName             = '';
  String _latitude                 = '';
  String _longitude                = '';
  String _flagColor                = '#434332';
  int? _dbId;

  // Flag Color Swatches
  final Map<String, String> _colorSwatches = {
    'Blackberry': '#434332',
    'Charcoal': '#212121',
    'Emerald': '#00897B',
    'Sapphire': '#1E88E5',
    'Crimson': '#E53935',
    'Amber': '#FFB300',
    'Grape': '#8E24AA',
    'Teal': '#009688',
  };

  @override
  void initState() {
    super.initState();
    if (widget.eventId != 'new') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateExistingEvent();
      });
    }
  }

  void _populateExistingEvent() {
    try {
      final homeState = ref.read(homeProvider);
      ClubEvent? foundEvent;
      for (final e in homeState.events) {
        if (e.id == widget.eventId) {
          foundEvent = e;
          break;
        }
      }

      if (foundEvent != null) {
        final event = foundEvent;
        debugPrint('═══ [EventEdit] Auto-fill Event Details ═══');
        debugPrint('title: ${event.title}');
        debugPrint('location: ${event.location}');
        debugPrint('locationDetails: ${event.locationDetails}');
        debugPrint('opponent: ${event.opponent}');
        debugPrint('extraLabel/subtitle: ${event.subtitle}');
        debugPrint('notes: ${event.notes}');
        debugPrint('flagColor: ${event.flagColor}');
        debugPrint('============================================');

        setState(() {
          _dbId = widget.duplicate ? null : event.dbId;
          _isScheduledGame = widget.duplicate ? false : (event.scheduleGameId != null);
          _eventNameController.text = event.title;
          _timeTbd = event.timeTbd;
          _selectedDateTime = event.dateTime;
          _durationMinutes = event.duration.inMinutes;
          _locationName = event.location;
          _latitude = event.latitude ?? '';
          _longitude = event.longitude ?? '';
          _locationDetailsController.text = event.locationDetails ?? '';
          _trackAvail = event.rsvpRequired;
          _opponentController.text = event.opponent ?? '';
          _extraLabelController.text = event.subtitle;
          _notesController.text = event.notes ?? '';
          _notifyTeam = event.notificationEnabled;
          _arrivalEarlyMinutes = event.arrivalEarly;
          _uniformColorController.text = event.uniformColor ?? '';
          _isCancelled = widget.duplicate ? false : (event.status == 2);

          // Map flag color robustly
          final parsedFlagColor = event.flagColor;
          if (parsedFlagColor != null && parsedFlagColor.isNotEmpty) {
            if (parsedFlagColor.startsWith('#')) {
              _flagColor = parsedFlagColor;
            } else {
              final lowerColor = parsedFlagColor.toLowerCase().trim();
              if (lowerColor.contains('green') || lowerColor == 'emerald') {
                _flagColor = '#00897B'; // Emerald
              } else if (lowerColor.contains('teal')) {
                _flagColor = '#009688'; // Teal
              } else if (lowerColor.contains('blue') || lowerColor == 'sapphire') {
                _flagColor = '#1E88E5'; // Sapphire
              } else if (lowerColor.contains('red') || lowerColor == 'crimson') {
                _flagColor = '#E53935'; // Crimson
              } else if (lowerColor.contains('amber') || lowerColor == 'yellow') {
                _flagColor = '#FFB300'; // Amber
              } else if (lowerColor.contains('purple') || lowerColor == 'grape') {
                _flagColor = '#8E24AA'; // Grape
              } else if (lowerColor.contains('black') || lowerColor == 'blackberry') {
                _flagColor = '#434332'; // Blackberry
              } else if (lowerColor == 'charcoal') {
                _flagColor = '#212121';
              } else {
                _flagColor = parsedFlagColor;
              }
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error populating event details: $e');
    }
  }

  Color _hexToColor(String hex) {
    try {
      final hexStr = hex.replaceFirst('#', '').replaceAll(' ', '');
      if (hexStr.length == 6) {
        return Color(int.parse('FF$hexStr', radix: 16));
      } else if (hexStr.length == 8) {
        return Color(int.parse(hexStr, radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF434332);
  }

  String _getColorName(String hex) {
    final matches = _colorSwatches.entries
        .where((e) => e.value.toLowerCase() == hex.toLowerCase());
    if (matches.isNotEmpty) {
      return matches.first.key;
    }
    return hex.toUpperCase();
  }



  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Select Date & Time';
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final year = dt.year.toString().substring(2);
    int hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    final hourStr = hour.toString();
    return '$month/$day/$year  $hourStr:$minute $period';
  }

  String _formatApiDateTime(DateTime dt) {
    final year = dt.year.toString();
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  String _formatDuration(int totalMinutes) {
    final hrs = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hrs > 0) {
      return '$hrs Hour${hrs > 1 ? 's' : ''} ${mins > 0 ? '$mins Minute${mins > 1 ? 's' : ''}' : ''}'.trim();
    }
    return '$mins Minute${mins > 1 ? 's' : ''}';
  }

  // ─── Time Picker Modal ──────────────────────────────────────────────────────

  Future<void> _pickDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.current.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.current.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!context.mounted) return;
      _showCupertinoTimePicker(pickedDate);
    }
  }

  void _showCupertinoTimePicker(DateTime baseDate) {
    final colors = AppColors.current;

    int selectedHour12 = baseDate.hour;
    final isPm = selectedHour12 >= 12;
    if (selectedHour12 > 12) selectedHour12 -= 12;
    if (selectedHour12 == 0) selectedHour12 = 12;

    int hourIndex = selectedHour12 - 1;
    int minuteIndex = baseDate.minute;
    int periodIndex = isPm ? 1 : 0;

    const double itemHeight = 44.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Time',
                            style: AppTextStyles.heading18.copyWith(color: colors.textPrimary),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: colors.textSecondary),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      SizedBox(
                        height: 180,
                        child: Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Hours Column
                                Expanded(
                                  child: ListWheelScrollView.useDelegate(
                                    itemExtent: itemHeight,
                                    perspective: 0.005,
                                    diameterRatio: 1.2,
                                    physics: const FixedExtentScrollPhysics(),
                                    controller: FixedExtentScrollController(initialItem: hourIndex),
                                    onSelectedItemChanged: (index) {
                                      setModalState(() {
                                        hourIndex = index % 12;
                                      });
                                    },
                                    childDelegate: ListWheelChildLoopingListDelegate(
                                      children: List.generate(12, (index) {
                                        final h = index + 1;
                                        final isSel = hourIndex == index;
                                        return Center(
                                          child: Text(
                                            '$h',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                                              color: isSel ? colors.primary : colors.textSecondary.withValues(alpha: 0.6),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                                
                                Text(
                                  ':',
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: colors.textPrimary),
                                ),
                                
                                // Minutes Column
                                Expanded(
                                  child: ListWheelScrollView.useDelegate(
                                    itemExtent: itemHeight,
                                    perspective: 0.005,
                                    diameterRatio: 1.2,
                                    physics: const FixedExtentScrollPhysics(),
                                    controller: FixedExtentScrollController(initialItem: minuteIndex),
                                    onSelectedItemChanged: (index) {
                                      setModalState(() {
                                        minuteIndex = index % 60;
                                      });
                                    },
                                    childDelegate: ListWheelChildLoopingListDelegate(
                                      children: List.generate(60, (index) {
                                        final m = index.toString().padLeft(2, '0');
                                        final isSel = minuteIndex == index;
                                        return Center(
                                          child: Text(
                                            m,
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                                              color: isSel ? colors.primary : colors.textSecondary.withValues(alpha: 0.6),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                                
                                // AM/PM Column
                                Expanded(
                                  child: ListWheelScrollView(
                                    itemExtent: itemHeight,
                                    perspective: 0.005,
                                    diameterRatio: 1.2,
                                    physics: const FixedExtentScrollPhysics(),
                                    controller: FixedExtentScrollController(initialItem: periodIndex),
                                    onSelectedItemChanged: (index) {
                                      setModalState(() {
                                        periodIndex = index;
                                      });
                                    },
                                    children: ['AM', 'PM'].map((p) {
                                      final isSel = (p == 'AM' && periodIndex == 0) || (p == 'PM' && periodIndex == 1);
                                      return Center(
                                        child: Text(
                                          p,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                                            color: isSel ? colors.primary : colors.textSecondary.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Selection highlighting borders overlay
                            IgnorePointer(
                              child: Center(
                                child: Container(
                                  height: itemHeight,
                                  decoration: BoxDecoration(
                                    border: Border.symmetric(
                                      horizontal: BorderSide(
                                        color: colors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            int finalHour = hourIndex + 1;
                            final bool isPmSelected = periodIndex == 1;
                            if (isPmSelected) {
                              if (finalHour < 12) finalHour += 12;
                            } else {
                              if (finalHour == 12) finalHour = 0;
                            }
    
                            setState(() {
                              _selectedDateTime = DateTime(
                                baseDate.year,
                                baseDate.month,
                                baseDate.day,
                                finalHour,
                                minuteIndex,
                              );
                            });
                            Navigator.pop(context);
                          },
                          child: Text('Confirm', style: AppTextStyles.heading15.copyWith(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Hour & Minute Slider Selector Sheets ───────────────────────────────────

  void _showDurationPicker({
    required String title,
    required int initialMinutes,
    required ValueChanged<int> onSelected,
  }) {
    int hours = initialMinutes ~/ 60;
    int minutes = initialMinutes % 60;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.current.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colors = AppColors.current;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.heading18.copyWith(color: colors.textPrimary),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: colors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text('Hours', style: AppTextStyles.body14.copyWith(color: colors.textSecondary)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline, color: colors.primary),
                                onPressed: hours > 0 ? () => setModalState(() => hours--) : null,
                              ),
                              Text('$hours', style: AppTextStyles.heading22.copyWith(color: colors.textPrimary)),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline, color: colors.primary),
                                onPressed: hours < 23 ? () => setModalState(() => hours++) : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        children: [
                          Text('Minutes', style: AppTextStyles.body14.copyWith(color: colors.textSecondary)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline, color: colors.primary),
                                onPressed: minutes >= 5 ? () => setModalState(() => minutes -= 5) : null,
                              ),
                              Text('$minutes', style: AppTextStyles.heading22.copyWith(color: colors.textPrimary)),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline, color: colors.primary),
                                onPressed: minutes < 55 ? () => setModalState(() => minutes += 5) : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        onSelected(hours * 60 + minutes);
                        Navigator.pop(context);
                      },
                      child: Text('Confirm', style: AppTextStyles.heading15.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Flag Color swatch selector ─────────────────────────────────────────────

  void _showColorPicker() {
    final initialColor = _hexToColor(_flagColor);
    int r = initialColor.red;
    int g = initialColor.green;
    int b = initialColor.blue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.current.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colors = AppColors.current;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final customColor = Color.fromARGB(255, r, g, b);
            final customHex = '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

            bool matchesPredefined = false;
            for (var entry in _colorSwatches.entries) {
              if (entry.value.toLowerCase() == customHex.toLowerCase()) {
                matchesPredefined = true;
                break;
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select Flag Color',
                            style: AppTextStyles.heading18.copyWith(color: colors.textPrimary),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: colors.textSecondary),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _colorSwatches.length,
                        itemBuilder: (context, index) {
                          final entry = _colorSwatches.entries.elementAt(index);
                          final name = entry.key;
                          final hex = entry.value;
                          final swatchColor = _hexToColor(hex);
                          final isSelected = customHex.toLowerCase() == hex.toLowerCase();

                          return GestureDetector(
                            onTap: () {
                              final tappedColor = _hexToColor(hex);
                              setState(() {
                                _flagColor = hex;
                              });
                              setModalState(() {
                                r = tappedColor.red;
                                g = tappedColor.green;
                                b = tappedColor.blue;
                              });
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: swatchColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? colors.primary : Colors.transparent,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                                      : null,
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: AppTextStyles.label12.copyWith(
                                      color: isSelected ? colors.primary : colors.textSecondary,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const Divider(height: 32),
                      
                      Text(
                        'Custom Color Selector',
                        style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: customColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: !matchesPredefined
                                ? const Icon(Icons.check, color: Colors.white, size: 24)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Custom RGB Swatch',
                                style: AppTextStyles.heading14.copyWith(color: colors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                customHex,
                                style: AppTextStyles.body14.copyWith(color: colors.primary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text('R', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                          Expanded(
                            child: Slider(
                              value: r.toDouble(),
                              min: 0,
                              max: 255,
                              activeColor: Colors.red,
                              inactiveColor: Colors.red.withValues(alpha: 0.2),
                              onChanged: (val) {
                                setModalState(() {
                                  r = val.toInt();
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text('$r', style: AppTextStyles.body14.copyWith(color: colors.textPrimary), textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                      
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text('G', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                          Expanded(
                            child: Slider(
                              value: g.toDouble(),
                              min: 0,
                              max: 255,
                              activeColor: Colors.green,
                              inactiveColor: Colors.green.withValues(alpha: 0.2),
                              onChanged: (val) {
                                setModalState(() {
                                  g = val.toInt();
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text('$g', style: AppTextStyles.body14.copyWith(color: colors.textPrimary), textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                      
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text('B', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                          Expanded(
                            child: Slider(
                              value: b.toDouble(),
                              min: 0,
                              max: 255,
                              activeColor: Colors.blue,
                              inactiveColor: Colors.blue.withValues(alpha: 0.2),
                              onChanged: (val) {
                                setModalState(() {
                                  b = val.toInt();
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text('$b', style: AppTextStyles.body14.copyWith(color: colors.textPrimary), textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            setState(() {
                              _flagColor = customHex;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Confirm Color',
                            style: AppTextStyles.heading15.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Google Places Autocomplete dropdown search modal ───────────────────────

  void _showLocationPicker() {
    final pageContext = context;
    final service = ref.read(eventDetailServiceProvider);
    final searchController = TextEditingController();
    final scrollController = ScrollController();
    List<dynamic> suggestions = [];
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.current.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colors = AppColors.current;
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<dynamic> displayList = [];
            if (isLoading) {
              displayList = [];
            } else {
              displayList = suggestions;
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Text(
                        'Search Location',
                        style: AppTextStyles.heading18.copyWith(color: colors.textPrimary),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: colors.textSecondary),
                        onPressed: () => Navigator.pop(pageContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: colors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            autofocus: true,
                            style: AppTextStyles.body16.copyWith(color: colors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Enter venue or city...',
                              hintStyle: AppTextStyles.body16.copyWith(color: colors.gray300),
                              border: InputBorder.none,
                            ),
                            onChanged: (val) async {
                              if (val.trim().isEmpty) {
                                setModalState(() {
                                  suggestions = [];
                                  isLoading = false;
                                });
                                return;
                              }

                              final apiKey = EnvironmentConfig.googleMapsApiKey;
                              if (apiKey.isEmpty) {
                                setModalState(() {});
                                return;
                              }

                              setModalState(() => isLoading = true);
                              try {
                                final apiSuggestions = await service.fetchPlacesAutocomplete(val);
                                setModalState(() {
                                  suggestions = apiSuggestions;
                                  isLoading = false;
                                });
                              } catch (_) {
                                setModalState(() => isLoading = false);
                              }
                            },
                          ),
                        ),
                        if (searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, color: colors.textSecondary, size: 18),
                            onPressed: () {
                              searchController.clear();
                              setModalState(() {
                                suggestions = [];
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final item = displayList[index];
                          String name = '';
                          String subtitle = '';

                          if (item is Map && item.containsKey('name')) {
                            name = item['name'] ?? '';
                            subtitle = item['description'] ?? '';
                          } else if (item is Map) {
                            name = item['structured_formatting']?['main_text'] ?? item['description'] ?? '';
                            subtitle = item['structured_formatting']?['secondary_text'] ?? '';
                          }

                          return InkWell(
                            onTap: () async {
                              if (item is Map && item.containsKey('latitude')) {
                                setState(() {
                                  _locationName = item['name']?.toString() ?? '';
                                  _latitude = item['latitude']?.toString() ?? '';
                                  _longitude = item['longitude']?.toString() ?? '';
                                });
                                setModalState(() {
                                  searchController.text = item['name']?.toString() ?? '';
                                });
                                await Future.delayed(const Duration(milliseconds: 300));
                                if (pageContext.mounted) Navigator.pop(pageContext);
                              } else if (item is Map) {
                                final placeId = item['place_id']?.toString() ?? '';
                                if (placeId.isNotEmpty) {
                                  setModalState(() {
                                    searchController.text = name;
                                    isLoading = true;
                                  });
                                  final details = await service.fetchPlaceDetails(placeId);
                                  final geometry = details?['geometry'];
                                  final lat = geometry?['location']?['lat']?.toString() ?? '35.9420';
                                  final lng = geometry?['location']?['lng']?.toString() ?? '-95.8833';

                                  setState(() {
                                    _locationName = name;
                                    _latitude = lat;
                                    _longitude = lng;
                                  });
                                  setModalState(() => isLoading = false);
                                  await Future.delayed(const Duration(milliseconds: 300));
                                  if (pageContext.mounted) Navigator.pop(pageContext);
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: colors.border.withValues(alpha: 0.3)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on_outlined, color: colors.primary, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: AppTextStyles.body16.copyWith(
                                            color: colors.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (subtitle.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            subtitle,
                                            style: AppTextStyles.body14.copyWith(color: colors.textSecondary),
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Save event invocation ────────────────────────────────────────────────

  Future<void> _onSave(EventAddEditState state, EventAddEditNotifier notifier) async {
    final eventName = _eventNameController.text.trim();
    if (eventName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Event name is required'),
          backgroundColor: AppColors.current.error,
        ),
      );
      return;
    }

    if (!RegExp(r'[a-zA-Z]').hasMatch(eventName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Title must contain at least one letter'),
          backgroundColor: AppColors.current.error,
        ),
      );
      return;
    }

    if (_selectedDateTime == null && !_timeTbd) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Event date is required'),
          backgroundColor: AppColors.current.error,
        ),
      );
      return;
    }

    if (state.selectedTimezone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Time zone is required'),
          backgroundColor: AppColors.current.error,
        ),
      );
      return;
    }

    final success = await notifier.saveEvent(
      id: widget.eventId != 'new' ? _dbId : null,
      eventName: eventName,
      startTime: _formatApiDateTime(_selectedDateTime ?? DateTime.now()),
      timezone: state.selectedTimezone!.key,
      timeTbd: _timeTbd,
      duration: _durationMinutes,
      location: _locationName,
      latitude: _latitude,
      longitude: _longitude,
      locationDetails: _locationDetailsController.text.trim(),
      arrivalEarly: _arrivalEarlyMinutes,
      trackAvailability: _trackAvail,
      flagColor: _flagColor,
      uniformColor: _uniformColorController.text.trim(),
      opponent: _opponentController.text.trim(),
      extraLabel: _extraLabelController.text.trim(),
      notes: _notesController.text.trim(),
      status: _isCancelled ? 2 : 1,
      notificationEnabled: _notifyTeam,
    );

    if (success) {
      if (mounted) {
        final successMsg = ref.read(eventAddEditProvider).saveSuccessMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg != null && successMsg.isNotEmpty ? successMsg : 'Event saved successfully'),
            backgroundColor: AppColors.current.primary,
          ),
        );

        final activeTeam = ref.read(selectedTeamProvider);
        if (activeTeam != null) {
          ref.read(homeProvider.notifier).fetchEvents(activeTeam.uuid);
          ref.read(scheduleProvider.notifier).fetchEvents(activeTeam.uuid);
        }

        context.go(widget.from == 'schedule' ? AppRoutes.schedule : AppRoutes.home);
      }
    } else {
      if (mounted) {
        final errMsg = ref.read(eventAddEditProvider).saveError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg != null && errMsg.isNotEmpty ? errMsg : 'Failed to save event'),
            backgroundColor: AppColors.current.error,
          ),
        );
      }
    }
  }

  Future<void> _onDelete(EventAddEditState state, EventAddEditNotifier notifier) async {
    final colors = AppColors.current;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.background,
        title: Text(
          'Delete Event',
          style: AppTextStyles.heading18.copyWith(color: colors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to permanently delete this event?',
          style: AppTextStyles.body16.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await notifier.deleteEvent(_dbId);

    if (success) {
      if (mounted) {
        final successMsg = ref.read(eventAddEditProvider).saveSuccessMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg != null && successMsg.isNotEmpty ? successMsg : 'Event deleted successfully'),
            backgroundColor: colors.primary,
          ),
        );
        
        final activeTeam = ref.read(selectedTeamProvider);
        if (activeTeam != null) {
          ref.read(homeProvider.notifier).fetchEvents(activeTeam.uuid);
          ref.read(scheduleProvider.notifier).fetchEvents(activeTeam.uuid);
        }

        context.go(widget.from == 'schedule' ? AppRoutes.schedule : AppRoutes.home);
      }
    } else {
      if (mounted) {
        final errMsg = ref.read(eventAddEditProvider).saveError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg != null && errMsg.isNotEmpty ? errMsg : 'Failed to delete event'),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  // ─── Timezone Selector dropdown ─────────────────────────────────────────────

  void _showTimezoneSheet(EventAddEditState state, EventAddEditNotifier notifier) {
    if (state.isLoadingTimezones) return;

    // If no timezones loaded yet, try fetching first
    if (state.timezones.isEmpty && state.timezonesError != null) {
      notifier.fetchTimezones();
      return;
    }

    final colors = AppColors.current;
    final sheetSearchController = TextEditingController();
    final sheetScrollController = ScrollController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final query = sheetSearchController.text.toLowerCase();
            final filtered = state.timezones.where((tz) {
              if (query.isEmpty) return true;
              return tz.label.toLowerCase().contains(query) ||
                  tz.key.toLowerCase().contains(query);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.75,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header ─────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 8, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Select Time Zone',
                              style: AppTextStyles.heading18
                                  .copyWith(color: colors.textPrimary),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: colors.textSecondary),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),

                    // ── Search bar ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: colors.border.withValues(alpha: 0.5)),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(Icons.search,
                                size: 18, color: colors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: sheetSearchController,
                                autofocus: false,
                                style: AppTextStyles.body15
                                    .copyWith(color: colors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Search timezone...',
                                  hintStyle: AppTextStyles.body15.copyWith(
                                      color: colors.textSecondary
                                          .withValues(alpha: 0.5)),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (_) => setSheet(() {}),
                              ),
                            ),
                            if (sheetSearchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  sheetSearchController.clear();
                                  setSheet(() {});
                                },
                                child: Icon(Icons.clear,
                                    size: 16,
                                    color: colors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Divider(
                        height: 1,
                        color: colors.border.withValues(alpha: 0.4)),

                    // ── List ────────────────────────────────────────────
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          query.isEmpty
                              ? 'No timezones available'
                              : 'No results for "$query"',
                          style: AppTextStyles.body15
                              .copyWith(color: colors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          controller: sheetScrollController,
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final tz = filtered[i];
                            final isSelected =
                                state.selectedTimezone == tz;
                            return InkWell(
                              onTap: () {
                                notifier.selectTimezone(tz);
                                Navigator.pop(ctx);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.primary
                                          .withValues(alpha: 0.08)
                                      : Colors.transparent,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: colors.border
                                          .withValues(alpha: 0.25),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tz.label,
                                        style: AppTextStyles.body15
                                            .copyWith(
                                          color: isSelected
                                              ? colors.primary
                                              : colors.textPrimary,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.check_circle,
                                          color: colors.primary, size: 18),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimezoneDropdownField(EventAddEditState timezoneState, EventAddEditNotifier notifier) {
    final colors = AppColors.current;

    return Opacity(
      opacity: _isScheduledGame ? 0.45 : 1.0,
      child: InkWell(
        onTap: _isScheduledGame
            ? null
            : (timezoneState.isSaving
                ? null
                : () => _showTimezoneSheet(timezoneState, notifier)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Time Zone',
                  style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
                ),
              ),
              if (timezoneState.isLoadingTimezones)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                )
              else if (timezoneState.timezonesError != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: colors.error, size: 16),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => notifier.fetchTimezones(),
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Flexible(
                  child: Text(
                    timezoneState.selectedTimezone?.label ?? 'Select timezone',
                    style: AppTextStyles.body16.copyWith(
                      color: timezoneState.selectedTimezone != null
                          ? colors.textSecondary
                          : colors.textSecondary.withValues(alpha: 0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 20, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _notesController.dispose();
    _eventNameController.dispose();
    _locationDetailsController.dispose();
    _extraLabelController.dispose();
    _timezoneSearchController.dispose();
    _timezoneScrollController.dispose();
    _uniformColorController.dispose();
    _opponentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timezoneState = ref.watch(eventAddEditProvider);
    final notifier = ref.read(eventAddEditProvider.notifier);
    final colors = AppColors.current;
    final isEdit = widget.eventId != 'new' && !widget.duplicate;

    // Pre-select matching timezone for existing event
    final hasExistingEvent = widget.eventId != 'new';
    if (hasExistingEvent && !_hasPrepopulatedTimezone && timezoneState.timezones.isNotEmpty) {
      final homeState = ref.read(homeProvider);
      ClubEvent? foundEvent;
      for (final e in homeState.events) {
        if (e.id == widget.eventId) {
          foundEvent = e;
          break;
        }
      }
      if (foundEvent != null && foundEvent.timezone != null) {
        TimezoneModel? matchingTz;
        for (final tz in timezoneState.timezones) {
          if (tz.key.toLowerCase().trim() == foundEvent.timezone!.toLowerCase().trim()) {
            matchingTz = tz;
            break;
          }
        }
        if (matchingTz != null) {
          _hasPrepopulatedTimezone = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifier.selectTimezone(matchingTz!);
          });
        }
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            SubHeader(
              title:      isEdit ? 'Edit Event' : 'Add Event',
              leftIcon:   Icons.close,
                                  leftLabel:  'Close',
              onLeftTap:  timezoneState.isSaving ? null : () => Navigator.maybePop(context),
              rightText:  timezoneState.isSaving ? 'Saving...' : 'Save',
              onRightTap: timezoneState.isSaving ? null : () => _onSave(timezoneState, notifier),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await notifier.refreshTimezones();
                  final activeTeam = ref.read(selectedTeamProvider);
                  if (activeTeam != null) {
                    await ref.read(homeProvider.notifier).fetchEvents(activeTeam.uuid);
                  }
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(19, 20, 19, 40),
                  children: [
                    // ── Notify Team ──────────────────────────────────────────────
                    EventEditNotifyCard(
                      value:     _notifyTeam,
                      onChanged: (v) => setState(() => _notifyTeam = v),
                    ),
                    const SizedBox(height: 20),

                    // ── Basic Details ────────────────────────────────────────────
                    EventEditFormCard(
                      icon:  Icons.calendar_today_outlined,
                      title: 'Basic Details',
                      children: [
                        EventEditInlineField(
                          label:        'Event Name',
                          controller:   _eventNameController,
                          placeholder:  'e.g. Game, Practice, Tournament',
                          borderBottom: true,
                          enabled:      !_isScheduledGame,
                        ),
                        EventEditListRow(
                          label: 'Date/Time',
                          value: _formatDateTime(_selectedDateTime),
                          onTap: () => _pickDateTime(context),
                          enabled: !_isScheduledGame,
                        ),
                        _buildTimezoneDropdownField(timezoneState, notifier),
                        EventEditToggleRow(
                          label:     'Time TBD',
                          value:     _timeTbd,
                          onChanged: (v) => setState(() => _timeTbd = v),
                        ),
                        EventEditListRow(
                          label: 'Duration',
                          value: _formatDuration(_durationMinutes),
                          borderBottom: false,
                          enabled: !_isScheduledGame,
                          onTap: () => _showDurationPicker(
                            title: 'Select Duration',
                            initialMinutes: _durationMinutes,
                            onSelected: (val) => setState(() => _durationMinutes = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Location ─────────────────────────────────────────────────
                    EventEditFormCard(
                      icon:  Icons.location_on_outlined,
                      title: 'Location',
                      children: [
                        EventEditListRow(
                          label: 'Location',
                          value: _locationName.isNotEmpty ? _locationName : 'Select Location',
                          onTap: () => _showLocationPicker(),
                          enabled: !_isScheduledGame,
                        ),
                        EventEditInlineField(
                          label:        'Location Details',
                          controller:   _locationDetailsController,
                          placeholder:  'e.g. Field #5, Turf Field',
                          borderBottom: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Logistics & Settings ─────────────────────────────────────
                    EventEditFormCard(
                      icon:  Icons.settings_outlined,
                      title: 'Logistics & Settings',
                      children: [
                        EventEditListRow(
                          label: 'Arrive Early',
                          value: '${_arrivalEarlyMinutes} Minutes',
                          onTap: () => _showDurationPicker(
                            title: 'Select Arrival Time',
                            initialMinutes: _arrivalEarlyMinutes,
                            onSelected: (val) => setState(() => _arrivalEarlyMinutes = val),
                          ),
                        ),
                        EventEditToggleRow(
                          label:     'Track Availability',
                          value:     _trackAvail,
                          onChanged: (v) => setState(() => _trackAvail = v),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: colors.border.withValues(alpha: 0.5))),
                          ),
                          child: InkWell(
                            onTap: () => _showColorPicker(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Flag Color',
                                      style: AppTextStyles.heading15.copyWith(color: colors.textPrimary),
                                    ),
                                  ),
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: _hexToColor(_flagColor),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getColorName(_flagColor),
                                    style: AppTextStyles.body16.copyWith(color: colors.textSecondary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.chevron_right, size: 20, color: colors.textSecondary),
                                ],
                              ),
                            ),
                          ),
                        ),
                        EventEditInlineField(
                          label:        'Uniform Color',
                          controller:   _uniformColorController,
                          placeholder:  'e.g. Blue, White / Green',
                          borderBottom: true,
                        ),
                        EventEditInlineField(
                          label:        'Opponent',
                          controller:   _opponentController,
                          placeholder:  'e.g. Rival FC',
                          borderBottom: true,
                          enabled:      !_isScheduledGame,
                        ),
                        EventEditInlineField(
                          label:        'Extra Label',
                          controller:   _extraLabelController,
                          placeholder:  'Optional secondary label',
                          borderBottom: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Notes ────────────────────────────────────────────────────
                    EventEditFormCard(
                      icon:  Icons.align_horizontal_left_outlined,
                      title: 'Notes',
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: AppTextField(
                            controller: _notesController,
                            hintText:   'Add any additional details or instructions for the team...',
                            minLines:   4,
                            maxLines:   8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // ── Danger Zone / Cancel Event ──────────────────────────────
                    EventEditDangerCard(
                      isEdit: isEdit,
                      isCancelled: _isCancelled,
                      onCancelledChanged: (v) => setState(() => _isCancelled = v),
                      onDelete: () => _onDelete(timezoneState, notifier),
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
}
