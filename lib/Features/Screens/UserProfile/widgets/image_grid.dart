import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CustomImageGrid extends StatefulWidget {
  final List<dynamic> items; // direct API response
  final int crossAxisCount;
  final double borderRadius;
  final EdgeInsets padding;
  final double tileAspectRatio; // width / height
  final void Function(int index, Map<String, dynamic> item)? onItemTap;

  const CustomImageGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 3,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(8.0),
    this.tileAspectRatio = 3 / 4,
    this.onItemTap,
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
        final item = widget.items[index] as Map<String, dynamic>;
        final imageUrl = item["image"].toString();
        final imageType = int.tryParse(item["ImageType"].toString()) ?? 0;

        return GestureDetector(
          onTap: () => widget.onItemTap?.call(index, item),
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

                  return SizedBox(
                    width: tileSize.width,
                    height: tileSize.height,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stack) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.broken_image),
                              ),
                            );
                          },
                        ),

                        if (imageType == 2)
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
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
                                        child: const Center(
                                          child: Icon(
                                            Icons.lock,
                                            color: Colors.white,
                                            size: 36,
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
                    ),
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
