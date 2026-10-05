import 'package:flutter/material.dart';
import '../../models/location_point.dart';
import '../../models/ride.dart';
import '../../theme/app_theme.dart';

class RouteMapView extends StatefulWidget {
  final Ride ride;
  final GeoPoint? vehiclePosition;
  final double vehicleHeadingAngle;
  final bool showLivePulse;
  final double height;
  final bool isInteractive;
  final VoidCallback? onExpandTap;

  const RouteMapView({
    super.key,
    required this.ride,
    this.vehiclePosition,
    this.vehicleHeadingAngle = 0.0,
    this.showLivePulse = true,
    this.height = 320,
    this.isInteractive = true,
    this.onExpandTap,
  });

  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final matrix = _transformationController.value.clone();
    matrix.scale(1.25, 1.25);
    _transformationController.value = matrix;
  }

  void _zoomOut() {
    final matrix = _transformationController.value.clone();
    matrix.scale(0.8, 0.8);
    _transformationController.value = matrix;
  }

  void _resetMap() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.beigeLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.beigeBorder, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Map Canvas with pan/zoom gestures
          InteractiveViewer(
            transformationController: _transformationController,
            panEnabled: widget.isInteractive,
            scaleEnabled: widget.isInteractive,
            minScale: 0.7,
            maxScale: 3.5,
            child: SizedBox(
              width: double.infinity,
              height: widget.height,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _VectorMapPainter(
                      ride: widget.ride,
                      vehiclePos: widget.vehiclePosition,
                      vehicleHeading: widget.vehicleHeadingAngle,
                      pulseValue: _pulseController.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),

          // Map HUD Overlays (Controls)
          if (widget.isInteractive)
            Positioned(
              right: 12,
              top: 12,
              child: Column(
                children: [
                  _MapControlButton(
                    icon: Icons.add,
                    tooltip: 'Zoom in',
                    onTap: _zoomIn,
                  ),
                  const SizedBox(height: 6),
                  _MapControlButton(
                    icon: Icons.remove,
                    tooltip: 'Zoom out',
                    onTap: _zoomOut,
                  ),
                  const SizedBox(height: 6),
                  _MapControlButton(
                    icon: Icons.my_location,
                    tooltip: 'Recenter route',
                    onTap: _resetMap,
                  ),
                  if (widget.onExpandTap != null) ...[
                    const SizedBox(height: 6),
                    _MapControlButton(
                      icon: Icons.fullscreen,
                      tooltip: 'Expand Map',
                      onTap: widget.onExpandTap!,
                    ),
                  ],
                ],
              ),
            ),

          // Map Floating Legend Badge
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.88),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accentAmber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.ride.distanceKm.toStringAsFixed(1)} km • Live Vector GPS',
                    style: const TextStyle(
                      color: AppColors.offWhiteSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.offWhiteSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.beigeBorder, width: 1),
        ),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(icon, size: 18, color: AppColors.black),
          ),
        ),
      ),
    );
  }
}

/// Custom Vector Map Canvas Painter
class _VectorMapPainter extends CustomPainter {
  final Ride ride;
  final GeoPoint? vehiclePos;
  final double vehicleHeading;
  final double pulseValue;

  _VectorMapPainter({
    required this.ride,
    this.vehiclePos,
    required this.vehicleHeading,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF4EFEA);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 1. Draw subtle background urban grid & terrain blocks
    _drawTerrainAndRoadGrid(canvas, size);

    // 2. Map coordinates bounds to canvas coordinates
    final points = ride.routePolyline.isNotEmpty
        ? ride.routePolyline
        : [ride.originCoords, ride.destinationCoords];

    final mappedPoints = _mapGeoToCanvas(points, size);
    if (mappedPoints.isEmpty) return;

    // 3. Draw Route Polyline Shadow & Glow
    final polyPath = Path();
    polyPath.moveTo(mappedPoints.first.dx, mappedPoints.first.dy);
    for (int i = 1; i < mappedPoints.length; i++) {
      polyPath.lineTo(mappedPoints[i].dx, mappedPoints[i].dy);
    }

    final polylineGlow = Paint()
      ..color = AppColors.accentAmber.withOpacity(0.35)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(polyPath, polylineGlow);

    final polylineCore = Paint()
      ..color = AppColors.black
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(polyPath, polylineCore);

    final polylineAmberStripe = Paint()
      ..color = AppColors.accentAmberLight
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(polyPath, polylineAmberStripe);

    // 4. Draw Intermediate Stops Waypoints
    if (ride.stops.isNotEmpty) {
      final stopPoints = _mapGeoToCanvas(
        ride.stops.map((s) => s.coordinates).toList(),
        size,
      );
      for (int i = 0; i < stopPoints.length; i++) {
        final pt = stopPoints[i];
        final stop = ride.stops[i];
        _drawStopPin(canvas, pt, stop.name, stop.isPickup, stop.isDropoff);
      }
    } else {
      _drawOriginPin(canvas, mappedPoints.first, ride.originName);
      _drawDestinationPin(canvas, mappedPoints.last, ride.destinationName);
    }

    // 5. Draw Vehicle Marker or Live Pulsing Pin
    if (vehiclePos != null) {
      final vCanvasPos = _singleGeoToCanvas(vehiclePos!, size);
      _drawAnimatedVehicle(canvas, vCanvasPos, vehicleHeading, pulseValue);
    } else {
      // User current position pulse at origin
      _drawPulseBeacon(canvas, mappedPoints.first, pulseValue);
    }
  }

  void _drawTerrainAndRoadGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE8E0D2).withOpacity(0.5)
      ..strokeWidth = 1.0;

    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Simulated secondary freeway crosslines
    final freewayPaint = Paint()
      ..color = const Color(0xFFDDD2C0)
      ..strokeWidth = 3.5;

    canvas.drawLine(
      Offset(0, size.height * 0.35),
      Offset(size.width, size.height * 0.45),
      freewayPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.75, size.height),
      freewayPaint,
    );

    // Water/Bay Area decorative contour
    final waterPaint = Paint()..color = const Color(0xFFE2EFF8);
    final waterPath = Path();
    waterPath.moveTo(size.width * 0.72, 0);
    waterPath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.4,
      size.width,
      size.height * 0.65,
    );
    waterPath.lineTo(size.width, 0);
    waterPath.close();
    canvas.drawPath(waterPath, waterPaint);
  }

  List<Offset> _mapGeoToCanvas(List<GeoPoint> points, Size size) {
    if (points.isEmpty) return [];

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final latPadding = (maxLat - minLat) * 0.22 + 0.005;
    final lngPadding = (maxLng - minLng) * 0.22 + 0.005;

    minLat -= latPadding;
    maxLat += latPadding;
    minLng -= lngPadding;
    maxLng += lngPadding;

    const double pad = 40.0;
    final double drawW = size.width - (pad * 2);
    final double drawH = size.height - (pad * 2);

    return points.map((p) {
      final double normalizedX = (p.longitude - minLng) / (maxLng - minLng);
      final double normalizedY = (maxLat - p.latitude) / (maxLat - minLat); // Invert Y
      return Offset(pad + (normalizedX * drawW), pad + (normalizedY * drawH));
    }).toList();
  }

  Offset _singleGeoToCanvas(GeoPoint point, Size size) {
    final points = ride.routePolyline.isNotEmpty
        ? ride.routePolyline
        : [ride.originCoords, ride.destinationCoords];

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final latPadding = (maxLat - minLat) * 0.22 + 0.005;
    final lngPadding = (maxLng - minLng) * 0.22 + 0.005;

    minLat -= latPadding;
    maxLat += latPadding;
    minLng -= lngPadding;
    maxLng += lngPadding;

    const double pad = 40.0;
    final double drawW = size.width - (pad * 2);
    final double drawH = size.height - (pad * 2);

    final double normalizedX = (point.longitude - minLng) / (maxLng - minLng);
    final double normalizedY = (maxLat - point.latitude) / (maxLat - minLat);
    return Offset(pad + (normalizedX * drawW), pad + (normalizedY * drawH));
  }

  void _drawOriginPin(Canvas canvas, Offset offset, String label) {
    // Green / Black origin marker
    final circlePaint = Paint()..color = AppColors.black;
    canvas.drawCircle(offset, 8, circlePaint);
    canvas.drawCircle(offset, 4, Paint()..color = AppColors.offWhiteSurface);

    _drawPinLabel(canvas, offset, label, AppColors.black);
  }

  void _drawDestinationPin(Canvas canvas, Offset offset, String label) {
    final circlePaint = Paint()..color = AppColors.accentAmber;
    canvas.drawCircle(offset, 9, circlePaint);
    canvas.drawCircle(offset, 4.5, Paint()..color = AppColors.offWhiteSurface);

    _drawPinLabel(canvas, offset, label, AppColors.accentAmberDark);
  }

  void _drawStopPin(Canvas canvas, Offset offset, String name, bool isPickup, bool isDropoff) {
    final Color pinColor = isPickup
        ? AppColors.black
        : (isDropoff ? AppColors.accentAmber : const Color(0xFF5A554C));

    canvas.drawCircle(
      offset,
      7,
      Paint()
        ..color = pinColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      offset,
      3.5,
      Paint()..color = AppColors.offWhiteSurface,
    );

    _drawPinLabel(canvas, offset, name, pinColor);
  }

  void _drawPinLabel(Canvas canvas, Offset offset, String text, Color color) {
    final span = TextSpan(
      text: text.length > 20 ? '${text.substring(0, 18)}...' : text,
      style: TextStyle(
        color: AppColors.black,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        background: Paint()
          ..color = AppColors.offWhiteSurface.withOpacity(0.9)
          ..strokeWidth = 14
          ..style = PaintingStyle.fill,
      ),
    );
    final tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(offset.dx - (tp.width / 2), offset.dy + 10));
  }

  void _drawAnimatedVehicle(Canvas canvas, Offset offset, double heading, double pulse) {
    // Pulsing radar ripple behind vehicle
    final rippleRadius = 14.0 + (pulse * 18.0);
    final ripplePaint = Paint()
      ..color = AppColors.accentAmber.withOpacity(1.0 - pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(offset, rippleRadius, ripplePaint);

    // Outer aura
    canvas.drawCircle(
      offset,
      14,
      Paint()..color = AppColors.accentAmber.withOpacity(0.3),
    );

    // Vehicle Disc
    canvas.drawCircle(
      offset,
      11,
      Paint()..color = AppColors.black,
    );

    // Directional pointer / car icon
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(heading);

    final carPaint = Paint()..color = AppColors.offWhiteSurface;
    final carPath = Path();
    carPath.moveTo(0, -6);
    carPath.lineTo(4, 5);
    carPath.lineTo(0, 3);
    carPath.lineTo(-4, 5);
    carPath.close();

    canvas.drawPath(carPath, carPaint);
    canvas.restore();
  }

  void _drawPulseBeacon(Canvas canvas, Offset offset, double pulse) {
    final rippleRadius = 10.0 + (pulse * 20.0);
    final ripplePaint = Paint()
      ..color = AppColors.accentAmber.withOpacity(1.0 - pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(offset, rippleRadius, ripplePaint);

    canvas.drawCircle(offset, 7, Paint()..color = AppColors.accentAmber);
    canvas.drawCircle(offset, 3.5, Paint()..color = AppColors.offWhiteSurface);
  }

  @override
  bool shouldRepaint(covariant _VectorMapPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.vehiclePos != vehiclePos ||
        oldDelegate.vehicleHeading != vehicleHeading;
  }
}
