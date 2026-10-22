import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../models/new_event_dropdown_options_model.dart';

enum EventLocationMode {
  ourLocations,
  savedLocation,
  offSiteAddress,
  tbd,
}

class EventLocationTabView extends StatelessWidget {
  final EventLocationMode selectedMode;
  final ValueChanged<EventLocationMode> onModeChanged;
  final TextEditingController addressController;
  final ValueChanged<String> onAddressChanged;
  final GlobalKey addressFieldKey;
  final LayerLink addressLayerLink;
  final VoidCallback onClearAddress;
  final String? selectedFacility;
  final ValueChanged<String?>? onFacilityChanged;
  final String? selectedField;
  final ValueChanged<String?>? onFieldChanged;
  final String? selectedSavedLocation;
  final ValueChanged<String?>? onSavedLocationChanged;

  // Real API objects from dropdown options
  final List<OurLocationVenue> ourLocationVenues;
  final OurLocationVenue? selectedVenue;
  final ValueChanged<OurLocationVenue?>? onVenueChanged;
  final OurLocationField? selectedFieldItem;
  final ValueChanged<OurLocationField?>? onFieldItemChanged;
  final List<SavedLocationItem> savedLocationItems;
  final SavedLocationItem? selectedSavedLocationItem;
  final ValueChanged<SavedLocationItem?>? onSavedLocationItemChanged;

  const EventLocationTabView({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
    this.selectedFacility,
    this.onFacilityChanged,
    this.selectedField,
    this.onFieldChanged,
    this.selectedSavedLocation,
    this.onSavedLocationChanged,
    required this.addressController,
    required this.onAddressChanged,
    required this.addressFieldKey,
    required this.addressLayerLink,
    required this.onClearAddress,
    this.ourLocationVenues = const [],
    this.selectedVenue,
    this.onVenueChanged,
    this.selectedFieldItem,
    this.onFieldItemChanged,
    this.savedLocationItems = const [],
    this.selectedSavedLocationItem,
    this.onSavedLocationItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    final isDark = colors.isDark;

    // Palette tailored to match the Web UI design
    const yellowAccent = Color(0xFFF5BD1F);
    final yellowBg = isDark ? yellowAccent.withValues(alpha: 0.18) : const Color(0xFFFEF9E0);
    final inputBg = isDark ? colors.card : const Color(0xFFF4F5F7);
    final borderColor = isDark ? colors.border : const Color(0xFFE5E7EB);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1D20);
    final helperColor = isDark ? colors.textSecondary : const Color(0xFF6B7280);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── "Where is this happening? *" ──
        RichText(
          text: TextSpan(
            text: 'Where is this happening? ',
            style: AppTextStyles.heading15.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w700,
            ),
            children: const [
              TextSpan(
                text: '*',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── 4 Segmented Location Type Buttons ──
        Row(
          children: [
            Expanded(
              child: _buildModeButton(
                title: 'Our Locations',
                mode: EventLocationMode.ourLocations,
                yellowAccent: yellowAccent,
                yellowBg: yellowBg,
                borderColor: borderColor,
                titleColor: titleColor,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildModeButton(
                title: 'Saved Location',
                mode: EventLocationMode.savedLocation,
                yellowAccent: yellowAccent,
                yellowBg: yellowBg,
                borderColor: borderColor,
                titleColor: titleColor,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildModeButton(
                title: 'Off-Site\nAddress',
                mode: EventLocationMode.offSiteAddress,
                yellowAccent: yellowAccent,
                yellowBg: yellowBg,
                borderColor: borderColor,
                titleColor: titleColor,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildModeButton(
                title: 'TBD',
                mode: EventLocationMode.tbd,
                yellowAccent: yellowAccent,
                yellowBg: yellowBg,
                borderColor: borderColor,
                titleColor: titleColor,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Dynamic Body based on Selected Mode ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildModeContent(
            context,
            yellowAccent: yellowAccent,
            inputBg: inputBg,
            borderColor: borderColor,
            titleColor: titleColor,
            helperColor: helperColor,
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required String title,
    required EventLocationMode mode,
    required Color yellowAccent,
    required Color yellowBg,
    required Color borderColor,
    required Color titleColor,
    required bool isDark,
  }) {
    final isSelected = selectedMode == mode;

    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? yellowBg : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? yellowAccent : borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.15,
            color: isSelected ? (isDark ? yellowAccent : const Color(0xFF1A1D20)) : (isDark ? Colors.white70 : const Color(0xFF4B5563)),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildModeContent(
    BuildContext context, {
    required Color yellowAccent,
    required Color inputBg,
    required Color borderColor,
    required Color titleColor,
    required Color helperColor,
  }) {
    switch (selectedMode) {
      case EventLocationMode.ourLocations:
        return _buildOurLocationsContent(
          context,
          inputBg: inputBg,
          borderColor: borderColor,
          titleColor: titleColor,
          helperColor: helperColor,
        );

      case EventLocationMode.savedLocation:
        return _buildSavedLocationContent(
          context,
          inputBg: inputBg,
          borderColor: borderColor,
          titleColor: titleColor,
          helperColor: helperColor,
        );

      case EventLocationMode.offSiteAddress:
        return _buildOffSiteAddressContent(
          context,
          inputBg: inputBg,
          borderColor: borderColor,
          titleColor: titleColor,
          helperColor: helperColor,
        );

      case EventLocationMode.tbd:
        return _buildTbdContent(helperColor: helperColor);
    }
  }

  // ── 1. Our Locations ────────────────────────────────────────────────────────
  Widget _buildOurLocationsContent(
    BuildContext context, {
    required Color inputBg,
    required Color borderColor,
    required Color titleColor,
    required Color helperColor,
  }) {
    final displayFacility = selectedVenue?.label ??
        (selectedVenue?.name.isNotEmpty == true ? selectedVenue!.name : null);

    final displayField = selectedFieldItem?.label ??
        (selectedFieldItem?.fieldName.isNotEmpty == true ? selectedFieldItem!.fieldName : null);

    final bool hasFacilitySelected = selectedVenue != null;
    final fieldsForFacility = selectedVenue?.fields ?? const <OurLocationField>[];

    return Column(
      key: const ValueKey('our_locations'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Facility *
        _buildFieldLabel('Facility', isRequired: true, titleColor: titleColor),
        const SizedBox(height: 8),
        _buildDropdownSelector(
          context,
          value: displayFacility,
          placeholder: ourLocationVenues.isEmpty ? 'No facilities available' : 'Select facility',
          inputBg: inputBg,
          titleColor: titleColor,
          helperColor: helperColor,
          onTap: () {
            if (ourLocationVenues.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No facilities available from API')),
              );
              return;
            }
            _openVenuePickerSheet(
              context,
              venues: ourLocationVenues,
              selectedVenue: selectedVenue,
              onSelected: (venue) {
                onVenueChanged?.call(venue);
                onFacilityChanged?.call(venue.name);
                onFieldItemChanged?.call(null);
                onFieldChanged?.call(null);
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // Field (optional)
        _buildFieldLabel('Field', isRequired: false, titleColor: titleColor),
        const SizedBox(height: 8),
        _buildDropdownSelector(
          context,
          value: displayField,
          placeholder: !hasFacilitySelected
              ? 'Select a facility first'
              : (fieldsForFacility.isEmpty ? 'No fields for this facility' : 'Select field'),
          isDisabled: !hasFacilitySelected || fieldsForFacility.isEmpty,
          inputBg: inputBg,
          titleColor: titleColor,
          helperColor: helperColor,
          onTap: (!hasFacilitySelected || fieldsForFacility.isEmpty)
              ? null
              : () {
                  _openFieldPickerSheet(
                    context,
                    fields: fieldsForFacility,
                    selectedField: selectedFieldItem,
                    onSelected: (field) {
                      onFieldItemChanged?.call(field);
                      onFieldChanged?.call(field.fieldName);
                    },
                  );
                },
        ),
        const SizedBox(height: 12),

        // Helper text
        Text(
          'Facilities and their fields come from Facility Management.',
          style: TextStyle(
            fontSize: 13,
            color: helperColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── 2. Saved Location ───────────────────────────────────────────────────────
  Widget _buildSavedLocationContent(
    BuildContext context, {
    required Color inputBg,
    required Color borderColor,
    required Color titleColor,
    required Color helperColor,
  }) {
    final displaySaved = selectedSavedLocationItem?.name ??
        (selectedSavedLocationItem?.location.isNotEmpty == true
            ? selectedSavedLocationItem!.location
            : null);

    return Column(
      key: const ValueKey('saved_location'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Saved Location', isRequired: true, titleColor: titleColor),
        const SizedBox(height: 8),
        _buildDropdownSelector(
          context,
          value: displaySaved,
          placeholder: savedLocationItems.isEmpty ? 'No saved locations available' : 'Select saved location',
          inputBg: inputBg,
          titleColor: titleColor,
          helperColor: helperColor,
          onTap: () {
            if (savedLocationItems.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No saved locations available from API')),
              );
              return;
            }
            _openSavedLocationPickerSheet(
              context,
              items: savedLocationItems,
              selectedItem: selectedSavedLocationItem,
              onSelected: (item) {
                onSavedLocationItemChanged?.call(item);
                onSavedLocationChanged?.call(item.name.isNotEmpty ? item.name : item.location);
              },
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          "Places your teams use often that aren't one of your facilities.",
          style: TextStyle(
            fontSize: 13,
            color: helperColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── 3. Off-Site Address ─────────────────────────────────────────────────────
  Widget _buildOffSiteAddressContent(
    BuildContext context, {
    required Color inputBg,
    required Color borderColor,
    required Color titleColor,
    required Color helperColor,
  }) {
    return Column(
      key: const ValueKey('off_site_address'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Address', isRequired: true, titleColor: titleColor),
        const SizedBox(height: 8),
        CompositedTransformTarget(
          link: addressLayerLink,
          child: Container(
            key: addressFieldKey,
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: addressController,
              onChanged: onAddressChanged,
              style: TextStyle(
                fontSize: 15,
                color: titleColor,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                hintText: 'e.g. 4820 Cross Creek Rd, Easley, SC 29640',
                hintStyle: TextStyle(
                  fontSize: 14.5,
                  color: helperColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: addressController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: onClearAddress,
                        child: Icon(Icons.close, color: helperColor, size: 20),
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Pick the address from the suggestions, such as an away field or a park.',
          style: TextStyle(
            fontSize: 13,
            color: helperColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── 4. TBD ──────────────────────────────────────────────────────────────────
  Widget _buildTbdContent({required Color helperColor}) {
    return Padding(
      key: const ValueKey('tbd'),
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        "Use this when the location isn't known yet. The event is saved without a location.",
        style: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: helperColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // ── Shared UI helpers ───────────────────────────────────────────────────────

  Widget _buildFieldLabel(String label, {required bool isRequired, required Color titleColor}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 14,
          color: titleColor,
          fontWeight: FontWeight.w700,
        ),
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildDropdownSelector(
    BuildContext context, {
    required String? value,
    required String placeholder,
    bool isDisabled = false,
    required Color inputBg,
    required Color titleColor,
    required Color helperColor,
    VoidCallback? onTap,
  }) {
    final hasValue = value != null && value.isNotEmpty;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: inputBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? value : placeholder,
                style: TextStyle(
                  fontSize: 15,
                  color: isDisabled
                      ? helperColor.withValues(alpha: 0.6)
                      : (hasValue ? titleColor : helperColor),
                  fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDisabled ? helperColor.withValues(alpha: 0.4) : const Color(0xFF9CA3AF),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _openVenuePickerSheet(
    BuildContext context, {
    required List<OurLocationVenue> venues,
    required OurLocationVenue? selectedVenue,
    required ValueChanged<OurLocationVenue> onSelected,
  }) {
    final colors = AppColors.current;
    final isDark = colors.isDark;
    String searchQuery = '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? colors.card : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filteredVenues = venues.where((v) {
              if (searchQuery.isEmpty) return true;
              final q = searchQuery.toLowerCase();
              return v.name.toLowerCase().contains(q) || v.label.toLowerCase().contains(q);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Facility',
                        style: AppTextStyles.heading18.copyWith(
                          color: isDark ? Colors.white : const Color(0xFF1A1D20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: colors.textSecondary,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Search bar
                  TextField(
                    onChanged: (val) => setModalState(() => searchQuery = val),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search facilities...',
                      prefixIcon: Icon(Icons.search, size: 20, color: colors.textSecondary),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor: isDark ? colors.background : const Color(0xFFF4F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: filteredVenues.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No facilities found',
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredVenues.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: isDark ? colors.border.withValues(alpha: 0.2) : const Color(0xFFF0F0F0),
                            ),
                            itemBuilder: (ctx, i) {
                              final venue = filteredVenues[i];
                              final isChosen = selectedVenue?.venueId == venue.venueId;

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                title: Text(
                                  venue.label.isNotEmpty ? venue.label : venue.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isChosen ? FontWeight.w700 : FontWeight.w500,
                                    color: isChosen ? const Color(0xFFF5BD1F) : (isDark ? Colors.white : const Color(0xFF1A1D20)),
                                  ),
                                ),
                                subtitle: venue.fields.isNotEmpty
                                    ? Text(
                                        '${venue.fields.length} resource(s) / field(s)',
                                        style: TextStyle(fontSize: 12, color: colors.textSecondary),
                                      )
                                    : null,
                                trailing: isChosen
                                    ? const Icon(Icons.check_circle, color: Color(0xFFF5BD1F), size: 22)
                                    : null,
                                onTap: () {
                                  onSelected(venue);
                                  Navigator.pop(ctx);
                                },
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

  void _openFieldPickerSheet(
    BuildContext context, {
    required List<OurLocationField> fields,
    required OurLocationField? selectedField,
    required ValueChanged<OurLocationField> onSelected,
  }) {
    final colors = AppColors.current;
    final isDark = colors.isDark;
    String searchQuery = '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? colors.card : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filteredFields = fields.where((f) {
              if (searchQuery.isEmpty) return true;
              final q = searchQuery.toLowerCase();
              return f.fieldName.toLowerCase().contains(q) || f.label.toLowerCase().contains(q);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Field / Resource',
                        style: AppTextStyles.heading18.copyWith(
                          color: isDark ? Colors.white : const Color(0xFF1A1D20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: colors.textSecondary,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  if (fields.length > 5) ...[
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (val) => setModalState(() => searchQuery = val),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search fields...',
                        prefixIcon: Icon(Icons.search, size: 20, color: colors.textSecondary),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: isDark ? colors.background : const Color(0xFFF4F5F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: fields.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No fields configured for this facility',
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            ),
                          )
                        : filteredFields.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    'No matching fields found',
                                    style: TextStyle(color: colors.textSecondary),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: filteredFields.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: isDark ? colors.border.withValues(alpha: 0.2) : const Color(0xFFF0F0F0),
                                ),
                                itemBuilder: (ctx, i) {
                                  final field = filteredFields[i];
                                  final isChosen = selectedField?.fieldId == field.fieldId;

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    title: Text(
                                      field.fieldName.isNotEmpty ? field.fieldName : field.label,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isChosen ? FontWeight.w700 : FontWeight.w500,
                                        color: isChosen ? const Color(0xFFF5BD1F) : (isDark ? Colors.white : const Color(0xFF1A1D20)),
                                      ),
                                    ),
                                    trailing: isChosen
                                        ? const Icon(Icons.check_circle, color: Color(0xFFF5BD1F), size: 22)
                                        : null,
                                    onTap: () {
                                      onSelected(field);
                                      Navigator.pop(ctx);
                                    },
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

  void _openSavedLocationPickerSheet(
    BuildContext context, {
    required List<SavedLocationItem> items,
    required SavedLocationItem? selectedItem,
    required ValueChanged<SavedLocationItem> onSelected,
  }) {
    final colors = AppColors.current;
    final isDark = colors.isDark;
    String searchQuery = '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? colors.card : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filteredItems = items.where((item) {
              if (searchQuery.isEmpty) return true;
              final q = searchQuery.toLowerCase();
              return item.name.toLowerCase().contains(q) ||
                  item.location.toLowerCase().contains(q) ||
                  item.address.toLowerCase().contains(q);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Saved Location',
                        style: AppTextStyles.heading18.copyWith(
                          color: isDark ? Colors.white : const Color(0xFF1A1D20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: colors.textSecondary,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Search bar
                  TextField(
                    onChanged: (val) => setModalState(() => searchQuery = val),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search saved locations...',
                      prefixIcon: Icon(Icons.search, size: 20, color: colors.textSecondary),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor: isDark ? colors.background : const Color(0xFFF4F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: filteredItems.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No saved locations found',
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredItems.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: isDark ? colors.border.withValues(alpha: 0.2) : const Color(0xFFF0F0F0),
                            ),
                            itemBuilder: (ctx, i) {
                              final item = filteredItems[i];
                              final isChosen = (selectedItem != null &&
                                      selectedItem.savedLocationId == item.savedLocationId) ||
                                  (selectedItem != null && selectedItem.id == item.id);

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                title: Text(
                                  item.name.isNotEmpty ? item.name : item.location,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isChosen ? FontWeight.w700 : FontWeight.w500,
                                    color: isChosen ? const Color(0xFFF5BD1F) : (isDark ? Colors.white : const Color(0xFF1A1D20)),
                                  ),
                                ),
                                subtitle: item.address.isNotEmpty && item.address != item.name
                                    ? Text(
                                        item.address,
                                        style: TextStyle(fontSize: 12, color: colors.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                                trailing: isChosen
                                    ? const Icon(Icons.check_circle, color: Color(0xFFF5BD1F), size: 22)
                                    : null,
                                onTap: () {
                                  onSelected(item);
                                  Navigator.pop(ctx);
                                },
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
}
