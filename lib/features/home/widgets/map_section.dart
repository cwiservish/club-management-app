import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Map Section with Live Google Map and Fallback ──────────────────────────────

class MapSection extends StatelessWidget {
  final String? latitude;
  final String? longitude;
  final String? location;

  const MapSection({
    super.key,
    this.latitude,
    this.longitude,
    this.location,
  });

  Future<void> _openGoogleMaps(BuildContext context, double? lat, double? lng) async {
    Uri? uri;
    if (lat != null && lng != null && (lat != 0.0 || lng != 0.0)) {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    } else if (location != null && location!.trim().isNotEmpty) {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location!)}');
    }

    if (uri != null) {
      try {
        final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open map.'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening map: $e'),
            ),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No location details available to show on map.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double? lat;
    double? lng;

    if (latitude != null && longitude != null) {
      lat = double.tryParse(latitude!);
      lng = double.tryParse(longitude!);
    }

    final hasValidCoordinates = lat != null && lng != null && (lat != 0.0 || lng != 0.0);

    return SizedBox(
      height: 134,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: const Color(0xFF1E2533)),
          ),
          if (hasValidCoordinates)
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat, lng),
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('${latitude}_$longitude'),
                    position: LatLng(lat, lng),
                  ),
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
              ),
            )
          else ...[
            CustomPaint(painter: MapGridPainter(), child: const SizedBox.expand()),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_pin, color: Colors.white54, size: 28),
                  SizedBox(height: 4),
                  Text('Map', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
          ],
          // Opaque detector to catch all tap events
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _openGoogleMaps(context, lat, lng),
              behavior: HitTestBehavior.opaque,
              child: const MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Grid painter fallback ───────────────────────────────────────────────────

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()
      ..color      = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    final road = Paint()
      ..color      = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 3;

    for (double y = 0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), light);
    }
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), light);
    }
    canvas.drawLine(
        Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.55), road);
    canvas.drawLine(
        Offset(size.width * 0.3, 0), Offset(size.width * 0.45, size.height), road);
  }

  @override
  bool shouldRepaint(_) => false;
}
