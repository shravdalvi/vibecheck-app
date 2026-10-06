import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../core/ui/filter_chip.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/crowd_level_chip.dart';
import '../../core/ui/error_state.dart';
import '../../core/ui/skeleton_loader.dart';
import '../../core/providers/mock_providers.dart';
import '../../core/providers/mock_map_provider.dart';
import '../../core/providers/profile_providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final TransformationController _transformController = TransformationController();
  bool _isPanning = false;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _recenter() {
    _transformController.value = Matrix4.identity();
    setState(() => _isPanning = false);
  }

  @override
  Widget build(BuildContext context) {
    final mapConfigAsync = ref.watch(mapConfigProvider);
    final activeRoute = ref.watch(activeRouteProvider);
    final selectedFilters = ref.watch(mapFiltersProvider);
    final isHighContrast = MediaQuery.highContrastOf(context);
    final sharingStatus = ref.watch(sharingStatusProvider);
    final userLocation = sharingStatus == SharingStatus.sharing ? ref.watch(userLocationProvider) : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.midnightInk,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Map', style: AppTypography.title),
        elevation: 0,
      ),
      body: mapConfigAsync.when(
        data: (config) => Stack(
          children: [
            // Interactive Map
            InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 4.0,
              onInteractionStart: (_) => setState(() => _isPanning = true),
              child: Center(
                child: SizedBox(
                  width: config.size.width,
                  height: config.size.height,
                  child: CustomPaint(
                    painter: MapPainter(
                      config: config,
                      userLocation: userLocation,
                      activeRoute: activeRoute,
                      filters: selectedFilters,
                      isHighContrast: isHighContrast,
                    ),
                  ),
                ),
              ),
            ),
            
            // Filters (under AppBar)
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + AppSpacing.sm,
              left: 0,
              right: 0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                child: Row(
                  children: [
                    _buildFilter('exit', 'Exits', PhosphorIconsRegular.doorOpen, selectedFilters),
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilter('medical', 'Medical', PhosphorIconsRegular.heart, selectedFilters),
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilter('toilet', 'Toilets', PhosphorIconsRegular.toilet, selectedFilters),
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilter('food', 'Food', PhosphorIconsRegular.forkKnife, selectedFilters),
                  ],
                ),
              ),
            ),
            
            // Legend Handle (Bottom Left)
            Positioned(
              bottom: AppSpacing.lg,
              left: AppSpacing.screenPadding,
              child: GestureDetector(
                onTap: () => _showLegend(context),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.slatePanel,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(PhosphorIconsRegular.info, color: AppColors.fog, size: 20),
                ),
              ),
            ),
            
            // Recenter Button (Bottom Right)
            if (_isPanning)
              Positioned(
                bottom: AppSpacing.lg + (activeRoute != null ? 80 : 0),
                right: AppSpacing.screenPadding,
                child: GestureDetector(
                  onTap: _recenter,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.slatePanel,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Icon(PhosphorIconsRegular.crosshair, color: AppColors.fog),
                  ),
                ),
              ),
              
            // Active Route Chip
            if (activeRoute != null)
              Positioned(
                bottom: AppSpacing.lg,
                left: 70, // Avoid legend
                right: AppSpacing.screenPadding,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.slatePanel,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsRegular.navigationArrow, color: AppColors.electricLime, size: 16),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(activeRoute.label, style: AppTypography.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      GestureDetector(
                        onTap: () => ref.read(activeRouteProvider.notifier).state = null,
                        child: Text('End route', style: AppTypography.label.copyWith(color: AppColors.fogSecondary)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        loading: () => const Padding(padding: EdgeInsets.only(top: 100), child: SkeletonRow()),
        error: (error, stack) => ErrorState(
          message: "We couldn't load the venue map. Check your connection and try again.",
          onRetry: () => ref.refresh(mapConfigProvider),
        ),
      ),
    );
  }

  Widget _buildFilter(String type, String label, IconData icon, Set<String> selectedFilters) {
    final isSelected = selectedFilters.contains(type);
    return AppFilterChip(
      label: label,
      icon: icon,
      isSelected: isSelected,
      onTap: () {
        final current = Set<String>.from(selectedFilters);
        if (isSelected) {
          current.remove(type);
        } else {
          current.add(type);
        }
        ref.read(mapFiltersProvider.notifier).state = current;
      },
    );
  }

  void _showLegend(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Crowd Levels', style: AppTypography.title),
                const SizedBox(height: AppSpacing.lg),
                _LegendRow(CrowdLevel.low),
                _LegendRow(CrowdLevel.moderate),
                _LegendRow(CrowdLevel.high),
                _LegendRow(CrowdLevel.critical),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(label: 'Close', onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LegendRow extends StatelessWidget {
  final CrowdLevel level;
  const _LegendRow(this.level);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(level.icon, color: level.color, size: 24),
          const SizedBox(width: AppSpacing.md),
          Text(level.label, style: AppTypography.body),
        ],
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final MapConfig config;
  final Point? userLocation;
  final RouteState? activeRoute;
  final Set<String> filters;
  final bool isHighContrast;

  MapPainter({
    required this.config,
    this.userLocation,
    this.activeRoute,
    required this.filters,
    required this.isHighContrast,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Zones
    for (final zone in config.zones) {
      final path = Path();
      if (zone.points.isNotEmpty) {
        path.moveTo(zone.points[0].x, zone.points[0].y);
        for (int i = 1; i < zone.points.length; i++) {
          path.lineTo(zone.points[i].x, zone.points[i].y);
        }
        path.close();
      }

      final fillOpacity = isHighContrast ? 0.30 : 0.18;
      final paint = Paint()
        ..color = zone.level.color.withValues(alpha: fillOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);

      // Outline
      final outlineOpacity = isHighContrast ? 1.0 : 0.70;
      final outlinePaint = Paint()
        ..color = zone.level.color.withValues(alpha: outlineOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHighContrast ? 2.0 : 1.5;
      canvas.drawPath(path, outlinePaint);
      
      // Mock hatching for high contrast
      if (isHighContrast && (zone.level == CrowdLevel.high || zone.level == CrowdLevel.critical)) {
         final hatchPaint = Paint()
           ..color = zone.level.color.withValues(alpha: 0.5)
           ..style = PaintingStyle.stroke
           ..strokeWidth = 1.0;
         // Just a conceptual mock: draw a diagonal line inside
         canvas.drawLine(Offset(zone.points[0].x, zone.points[0].y), Offset(zone.points[2].x, zone.points[2].y), hatchPaint);
      }

      // Draw Label
      final textPainter = TextPainter(
        text: TextSpan(text: zone.name, style: AppTypography.label.copyWith(color: AppColors.fog)),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      
      // Calculate center for label (rough center of bounding box)
      double minX = double.infinity, maxX = double.negativeInfinity;
      double minY = double.infinity, maxY = double.negativeInfinity;
      for (final p in zone.points) {
        if (p.x < minX) minX = p.x;
        if (p.x > maxX) maxX = p.x;
        if (p.y < minY) minY = p.y;
        if (p.y > maxY) maxY = p.y;
      }
      final cx = minX + (maxX - minX) / 2 - textPainter.width / 2;
      final cy = minY + (maxY - minY) / 2 - textPainter.height / 2;
      textPainter.paint(canvas, Offset(cx, cy));
    }

    // 2. Draw Route (lime dashed line)
    if (activeRoute != null && activeRoute!.path.isNotEmpty) {
      final routePaint = Paint()
        ..color = AppColors.electricLime
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      
      final path = Path();
      path.moveTo(activeRoute!.path[0].x, activeRoute!.path[0].y);
      for (int i = 1; i < activeRoute!.path.length; i++) {
        path.lineTo(activeRoute!.path[i].x, activeRoute!.path[i].y);
      }
      
      // Since native flutter doesn't have an easy dashed line built-in without an external package,
      // we mock it here with a solid line for the CustomPainter, but real impl would use dash_path.
      canvas.drawPath(path, routePaint);
      
      // Destination Pin
      final dest = activeRoute!.path.last;
      final destPaint = Paint()..color = AppColors.electricLime;
      canvas.drawCircle(Offset(dest.x, dest.y), 10, destPaint);
      final destInnerPaint = Paint()..color = AppColors.fog;
      canvas.drawCircle(Offset(dest.x, dest.y), 4, destInnerPaint);
    }

    // 3. Draw You Are Here
    if (userLocation != null) {
      // soft 28px lime ring at 25% opacity
      final ringPaint = Paint()..color = AppColors.electricLime.withValues(alpha: 0.25);
      canvas.drawCircle(Offset(userLocation!.x, userLocation!.y), 14, ringPaint); // 28px diameter = 14px radius
      
      // solid lime dot 12px
      final dotPaint = Paint()..color = AppColors.electricLime;
      canvas.drawCircle(Offset(userLocation!.x, userLocation!.y), 6, dotPaint); // 12px diameter = 6px radius
    }

    // 4. Draw POIs
    for (final poi in config.pois) {
      final isSelected = filters.contains(poi.type);
      final isDefaultVisible = poi.type == 'exit' || poi.type == 'medical';
      
      if (!isSelected && !isDefaultVisible) continue;
      
      final opacity = isSelected ? 1.0 : 0.4;
      final poiPaint = Paint()
        ..color = AppColors.fog.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(Offset(poi.location.x, poi.location.y), 12, poiPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.config != config ||
           oldDelegate.userLocation != userLocation ||
           oldDelegate.activeRoute != activeRoute ||
           oldDelegate.filters != filters ||
           oldDelegate.isHighContrast != isHighContrast;
  }
}
