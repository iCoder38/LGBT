import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lgbt_togo/Features/Screens/Subscription/subscription.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

// Make sure you have your full-screen viewer imported where it's defined.
// Example:
// import 'package:your_app/Features/Screens/UserProfile/widgets/custom_fullscreen_viewer.dart';
//
// The viewer should accept: imageUrls: List<String>, initialIndex: int
// If your viewer has a different API, adjust the Navigator.push call accordingly.

class CustomImageGrid extends StatefulWidget {
  final List<dynamic>
  items; // direct API response (each item should be Map<String, dynamic>)
  final int crossAxisCount;
  final double borderRadius;
  final EdgeInsets padding;
  final double tileAspectRatio; // width / height
  final void Function(int index, Map<String, dynamic> item)? onItemTap;

  // NEW defaults that the parent can pass (used when item doesn't contain keys)
  final int friendStatusDefault; // 1 or 2
  final bool isPremiumDefault;

  /// Called when the user taps "Get Premium" in the premium-only dialog.
  /// Parent should open subscription/subscription flow here.
  final VoidCallback? onUpgradeTap;

  const CustomImageGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 3,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(8.0),
    this.tileAspectRatio = 3 / 4,
    this.onItemTap,
    this.friendStatusDefault = 1,
    this.isPremiumDefault = false,
    this.onUpgradeTap,
  });

  @override
  State<CustomImageGrid> createState() => _CustomImageGridState();
}

class _CustomImageGridState extends State<CustomImageGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Sparkle> _makeSparklesForIndex(int index, Size size) {
    final rand = Random(index);
    final count = 14 + rand.nextInt(14); // 14..27 sparkles
    final List<Sparkle> list = [];
    for (int i = 0; i < count; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height;
      final radius = 0.8 + rand.nextDouble() * 2.6; // star size
      final speed = 0.25 + rand.nextDouble() * 1.0;
      final phase = rand.nextDouble() * pi * 2;
      final direction = rand.nextDouble() * 2 * pi;
      final twist = rand.nextDouble() * pi; // rotation offset for some stars
      list.add(
        Sparkle(
          base: Offset(dx, dy),
          radius: radius,
          speed: speed,
          phase: phase,
          direction: direction,
          twist: twist,
        ),
      );
    }
    return list;
  }

  // Determines whether an item should be visible to the viewer
  // Uses per-item keys if present, otherwise falls back to widget defaults
  bool _isItemVisible(Map<String, dynamic> item) {
    final imageType = int.tryParse(item["ImageType"]?.toString() ?? '0') ?? 0;

    final perItemFriendStatus = int.tryParse(
      item["friendStatus"]?.toString() ?? '',
    );
    final friendStatus = perItemFriendStatus ?? widget.friendStatusDefault;

    bool itemIsPremium;
    if (item.containsKey("ispremium")) {
      final raw = item["ispremium"];
      if (raw is bool) {
        itemIsPremium = raw;
      } else if (raw != null) {
        final s = raw.toString().toLowerCase();
        itemIsPremium = (s == 'true' || s == '1');
      } else {
        itemIsPremium = widget.isPremiumDefault;
      }
    } else {
      itemIsPremium = widget.isPremiumDefault;
    }

    // rules:
    // - friendStatus == 2 -> show everything
    // - else if itemIsPremium == true -> show everything
    // - else hide only imageType == 2
    final showAllBecauseFriend = (friendStatus == 2);
    final showAllBecausePremium = itemIsPremium;
    final canViewAll = showAllBecauseFriend || showAllBecausePremium;
    final hidePrivate = (!canViewAll) && (imageType == 2);

    return !hidePrivate;
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Premium required"),
          content: const Text(
            "Only premium members can view this image.\nWould you like to upgrade to Premium?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                NavigationUtils.pushTo(context, SubscriptionScreen());
              },
              child: const Text("Get Premium"),
            ),
          ],
        );
      },
    );
  }

  // Build the visible-only list of image URLs (keeps order as in widget.items)
  List<String> _buildVisibleImageUrls() {
    final visible = <String>[];
    for (final raw in widget.items) {
      if (raw is Map<String, dynamic>) {
        if (_isItemVisible(raw)) {
          final url = raw["image"]?.toString() ?? '';
          if (url.isNotEmpty) visible.add(url);
        }
      }
    }
    return visible;
  }

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final itemRaw = widget.items[index];
        final item = (itemRaw is Map<String, dynamic>)
            ? itemRaw
            : <String, dynamic>{};
        final imageUrl = item["image"]?.toString() ?? '';

        // existing fields
        final imageType =
            int.tryParse(item["ImageType"]?.toString() ?? '0') ?? 0;

        // Per-item friendStatus (if present), else use widget.friendStatusDefault
        final perItemFriendStatus = int.tryParse(
          item["friendStatus"]?.toString() ?? '',
        );
        final friendStatus = perItemFriendStatus ?? widget.friendStatusDefault;

        // Per-item isPremium (if present), else use widget.isPremiumDefault
        bool isPremium;
        if (item.containsKey("ispremium")) {
          final raw = item["ispremium"];
          if (raw is bool) {
            isPremium = raw;
          } else if (raw != null) {
            final s = raw.toString().toLowerCase();
            isPremium = (s == 'true' || s == '1');
          } else {
            isPremium = widget.isPremiumDefault;
          }
        } else {
          isPremium = widget.isPremiumDefault;
        }

        final bool showAllBecauseFriend = (friendStatus == 2);
        final bool showAllBecausePremium = isPremium;
        final bool canViewAll = showAllBecauseFriend || showAllBecausePremium;
        final hidePrivate = (!canViewAll) && (imageType == 2);

        return GestureDetector(
          onTap: () {
            if (hidePrivate) {
              // Show premium dialog
              _showPremiumDialog(context);
            } else {
              // Build visible-only list and open viewer at the tapped image's index within visible list
              final visibleImageUrls = _buildVisibleImageUrls();

              // Determine initial index by matching image URL; fallback to 0
              final tappedUrl = imageUrl;
              int initialIndex = 0;
              if (tappedUrl.isNotEmpty) {
                final idx = visibleImageUrls.indexWhere((u) => u == tappedUrl);
                initialIndex = idx >= 0 ? idx : 0;
              }

              // If there are no visible images (rare), simply return
              if (visibleImageUrls.isEmpty) return;

              // Open the full-screen viewer — adjust import / viewer API as required
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomFullScreenImageViewer(
                    imageUrls: visibleImageUrls,
                    initialIndex: initialIndex,
                  ),
                ),
              );

              // still notify parent if it wants the raw tap (optional)
              if (widget.onItemTap != null) {
                widget.onItemTap!(index, item);
              }
            }
          },
          child: Padding(
            padding: widget.padding,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tileWidth = constraints.maxWidth.isFinite
                      ? constraints.maxWidth
                      : MediaQuery.of(context).size.width /
                            widget.crossAxisCount;
                  final tileHeight = tileWidth / widget.tileAspectRatio;
                  final tileSize = Size(tileWidth, tileHeight);

                  Widget content;
                  if (hidePrivate) {
                    // Do NOT load the network image for privacy: show placeholder + crown + sparkles
                    content = Container(
                      color: Colors.blue.shade900.withOpacity(0.6),
                      child: RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            return CustomPaint(
                              size: tileSize,
                              painter: _StarSparklePainter(
                                time: _controller.value,
                                sparkles: _makeSparklesForIndex(
                                  index,
                                  tileSize,
                                ),
                                borderRadius: widget.borderRadius,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.workspace_premium, // crown
                                  color: Colors.amber.shade800, // richer gold
                                  size: 42,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    // show the actual image (with loading/error states)
                    content = Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: tileSize.width,
                      height: tileSize.height,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stack) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.broken_image)),
                        );
                      },
                    );
                  }

                  return SizedBox(
                    width: tileSize.width,
                    height: tileSize.height,
                    child: content,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Simple data holder for sparkles
class Sparkle {
  final Offset base;
  final double radius;
  final double speed;
  final double phase;
  final double direction;
  final double twist;

  Sparkle({
    required this.base,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.direction,
    required this.twist,
  });
}

/// Painter that draws **star-shaped** sparkles (sharp 4-point + diamond center)
class _StarSparklePainter extends CustomPainter {
  final double time; // 0..1
  final List<Sparkle> sparkles;
  final double borderRadius;

  _StarSparklePainter({
    required this.time,
    required this.sparkles,
    required this.borderRadius,
  });

  final Paint _fill = Paint()..style = PaintingStyle.fill;
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  Path _diamond(Offset center, double w, double h) {
    final p = Path();
    p.moveTo(center.dx, center.dy - h / 2);
    p.lineTo(center.dx + w / 2, center.dy);
    p.lineTo(center.dx, center.dy + h / 2);
    p.lineTo(center.dx - w / 2, center.dy);
    p.close();
    return p;
  }

  Path _fourPointStar(
    Offset center,
    double outer,
    double inner,
    double rotation,
  ) {
    final Path path = Path();
    for (int i = 0; i < 4; i++) {
      final aOuter = rotation + i * pi / 2;
      final aInner = rotation + (i * pi / 2) + pi / 4;
      final pOuter = Offset(
        center.dx + cos(aOuter) * outer,
        center.dy + sin(aOuter) * outer,
      );
      final pInner = Offset(
        center.dx + cos(aInner) * inner,
        center.dy + sin(aInner) * inner,
      );
      if (i == 0) {
        path.moveTo(pOuter.dx, pOuter.dy);
      } else {
        path.lineTo(pOuter.dx, pOuter.dy);
      }
      path.lineTo(pInner.dx, pInner.dy);
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // clip to rounded rect so stars don't overflow
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );
    canvas.clipRRect(rrect);

    final double t = time * 2 * pi; // reuse

    for (final s in sparkles) {
      // smooth drifting motion
      final dx =
          s.base.dx + (cos(t * s.speed + s.phase) * 6.0 * sin(s.direction));
      final dy =
          s.base.dy + (sin(t * s.speed + s.phase) * 4.0 * cos(s.direction));
      final pos = Offset(dx, dy);

      // twinkle alpha
      final alpha = (0.4 + 0.6 * (0.5 + 0.5 * sin(t * s.speed + s.phase)))
          .clamp(0.12, 1.0);
      final color = Colors.white.withOpacity(alpha);

      // glow (soft outer)
      final glow = Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawPath(_diamond(pos, s.radius * 3.4, s.radius * 3.4), glow);

      // bright star core - four pointed star
      _fill.color = color;
      final outer = s.radius * 2.6;
      final inner = s.radius * 0.9;
      final rotation = t * 0.6 + s.twist;
      final starPath = _fourPointStar(pos, outer, inner, rotation);
      canvas.drawPath(starPath, _fill);

      // small diamond center (sharper highlight)
      _fill.color = Colors.white.withOpacity((alpha * 0.9).clamp(0.5, 1.0));
      final centerDiamond = _diamond(pos, s.radius * 1.8, s.radius * 1.8);
      canvas.drawPath(centerDiamond, _fill);

      // subtle outline to define shape
      _stroke
        ..color = Colors.white.withOpacity(alpha * 0.6)
        ..strokeWidth = (s.radius * 0.35).clamp(0.2, 1.5);
      canvas.drawPath(starPath, _stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _StarSparklePainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.sparkles.length != sparkles.length;
  }
}
