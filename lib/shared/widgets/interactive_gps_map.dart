import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class InteractiveGpsMap extends StatefulWidget {
  final double height;
  final bool isTrackingMode; // True for live driver delivery, false for address pin
  final String destinationAddress;
  final VoidCallback? onLocationPicked;

  const InteractiveGpsMap({
    super.key,
    this.height = 280,
    this.isTrackingMode = true,
    this.destinationAddress = 'Haware Splendor, Sector 20',
    this.onLocationPicked,
  });

  @override
  State<InteractiveGpsMap> createState() => _InteractiveGpsMapState();
}

class _InteractiveGpsMapState extends State<InteractiveGpsMap> with SingleTickerProviderStateMixin {
  late AnimationController _riderController;
  late Animation<double> _riderProgress;
  Timer? _pulseTimer;
  double _pulseRadius = 12.0;

  // Road waypoints for delivery route
  final List<Offset> _routeWaypoints = const [
    Offset(60, 210),   // Restaurant Origin
    Offset(110, 210),
    Offset(110, 140),
    Offset(190, 140),
    Offset(190, 75),
    Offset(290, 75),   // Customer Destination
  ];

  @override
  void initState() {
    super.initState();
    _riderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _riderProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _riderController, curve: Curves.easeInOut),
    );

    _pulseTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (mounted) {
        setState(() {
          _pulseRadius = _pulseRadius == 12.0 ? 22.0 : 12.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _riderController.dispose();
    _pulseTimer?.cancel();
    super.dispose();
  }

  Offset _getInterpolatedPosition(double t) {
    if (_routeWaypoints.length < 2) return const Offset(150, 150);
    double totalLength = 0.0;
    List<double> segmentLengths = [];
    for (int i = 0; i < _routeWaypoints.length - 1; i++) {
      double len = (_routeWaypoints[i + 1] - _routeWaypoints[i]).distance;
      segmentLengths.add(len);
      totalLength += len;
    }

    double targetDist = t * totalLength;
    double currentDist = 0.0;

    for (int i = 0; i < segmentLengths.length; i++) {
      if (currentDist + segmentLengths[i] >= targetDist) {
        double segT = (targetDist - currentDist) / segmentLengths[i];
        return Offset.lerp(_routeWaypoints[i], _routeWaypoints[i + 1], segT) ?? _routeWaypoints[i];
      }
      currentDist += segmentLengths[i];
    }
    return _routeWaypoints.last;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E3DF), // Standard OpenStreetMap land background
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [AppColors.softShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Interactive Pan and Zoom Canvas
            InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(80),
              minScale: 0.8,
              maxScale: 2.5,
              child: SizedBox(
                width: 360,
                height: widget.height,
                child: AnimatedBuilder(
                  animation: _riderProgress,
                  builder: (context, child) {
                    final riderPos = _getInterpolatedPosition(_riderProgress.value);
                    return CustomPaint(
                      painter: _MapCanvasPainter(
                        waypoints: _routeWaypoints,
                        riderPosition: riderPos,
                        isTrackingMode: widget.isTrackingMode,
                        pulseRadius: _pulseRadius,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Live Status Floating Overlay Pill
            if (widget.isTrackingMode)
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [AppColors.softShadow],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.gps_fixed, color: Colors.greenAccent, size: 14),
                      SizedBox(width: 6),
                      Text('LIVE GPS • 32 km/h', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            // Map Action Controls (Zoom in / Center)
            Positioned(
              bottom: 14,
              right: 14,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: const [AppColors.softShadow]),
                    child: const Icon(Icons.my_location, color: AppColors.primary, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  final List<Offset> waypoints;
  final Offset riderPosition;
  final bool isTrackingMode;
  final double pulseRadius;

  _MapCanvasPainter({
    required this.waypoints,
    required this.riderPosition,
    required this.isTrackingMode,
    required this.pulseRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Parks / Green Areas
    final parkPaint = Paint()..color = const Color(0xFFC8E6C9);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(18, 18, 90, 80), const Radius.circular(16)), parkPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(240, 140, 100, 90), const Radius.circular(20)), parkPaint);

    // 2. City Streets / Road Grid (White lines with dark borders)
    final roadBorderPaint = Paint()
      ..color = const Color(0xFFD0CDCE)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path gridPath = Path();
    // Horizontal streets
    gridPath.moveTo(0, 75);
    gridPath.lineTo(360, 75);
    gridPath.moveTo(0, 140);
    gridPath.lineTo(360, 140);
    gridPath.moveTo(0, 210);
    gridPath.lineTo(360, 210);
    // Vertical avenues
    gridPath.moveTo(60, 0);
    gridPath.lineTo(60, size.height);
    gridPath.moveTo(110, 0);
    gridPath.lineTo(110, size.height);
    gridPath.moveTo(190, 0);
    gridPath.lineTo(190, size.height);
    gridPath.moveTo(290, 0);
    gridPath.lineTo(290, size.height);

    canvas.drawPath(gridPath, roadBorderPaint);
    canvas.drawPath(gridPath, roadPaint);

    // 3. Navigation Route (Coral Primary Glow Polyline)
    if (isTrackingMode && waypoints.isNotEmpty) {
      final routeBorder = Paint()
        ..color = AppColors.primaryDark
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final routePaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final Path routePath = Path();
      routePath.moveTo(waypoints.first.dx, waypoints.first.dy);
      for (int i = 1; i < waypoints.length; i++) {
        routePath.lineTo(waypoints[i].dx, waypoints[i].dy);
      }

      canvas.drawPath(routePath, routeBorder);
      canvas.drawPath(routePath, routePaint);

      // 4. Restaurant Origin Marker
      final origin = waypoints.first;
      final restoPaint = Paint()..color = Colors.purple;
      canvas.drawCircle(origin, 14, restoPaint);
      final whiteDot = Paint()..color = Colors.white;
      canvas.drawCircle(origin, 5, whiteDot);

      // 5. Customer Destination Pulse Ring & Pin
      final destination = waypoints.last;
      final pulsePaint = Paint()
        ..color = AppColors.primary.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(destination, pulseRadius, pulsePaint);

      final destPaint = Paint()..color = AppColors.primary;
      canvas.drawCircle(destination, 15, destPaint);
      canvas.drawCircle(destination, 6, whiteDot);

      // 6. Animated Rider Marker (Motorcycle / Delivery Hero)
      final riderBgPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;
      canvas.drawCircle(riderPosition, 16, riderBgPaint);

      final riderInnerPaint = Paint()
        ..color = Colors.tealAccent
        ..style = PaintingStyle.fill;
      canvas.drawCircle(riderPosition, 13, riderInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) => true;
}
