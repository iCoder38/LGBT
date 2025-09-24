import 'package:flutter/material.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';
import 'content_text.dart';

class ContentImage extends StatelessWidget {
  final String? text;
  final List<String> images;
  final VoidCallback? onViewMoreTap;
  final void Function(int index)? onImageTap;

  const ContentImage({
    super.key,
    this.text,
    required this.images,
    this.onViewMoreTap,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show text first if available
        if (text != null && text!.trim().isNotEmpty) ...[
          ContentText(text: text!),
          const SizedBox(height: 8),
        ],

        // Show image(s) depending on count
        if (images.length == 1)
          _singleImage(context, 0)
        else if (images.length == 2 || images.length == 3)
          _horizontalRow(context)
        else
          _gridPreview(context),
      ],
    );
  }

  // Single image full-width (16:9)
  Widget _singleImage(BuildContext context, int index) {
    final url = images[index];
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => onImageTap?.call(index),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _errorBox(),
                loadingBuilder: (c, child, progress) =>
                    progress == null ? child : _loaderBox(),
              ),
            ),
            _imageCountBadge(), // ✅ total images badge
          ],
        ),
      ),
    );
  }

  // 2 or 3 images: show in one horizontal scrollable row
  Widget _horizontalRow(BuildContext context) {
    final double height = 160;
    final double tileWidth = MediaQuery.of(context).size.width * 0.6;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final url = images[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GestureDetector(
                  onTap: () => onImageTap?.call(index),
                  child: Image.network(
                    url,
                    width: tileWidth,
                    height: height,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => _errorBox(),
                    loadingBuilder: (c, child, progress) =>
                        progress == null ? child : _loaderBox(),
                  ),
                ),
              );
            },
          ),
          _imageCountBadge(), // ✅ total images badge
        ],
      ),
    );
  }

  // 4+ images: show 2x2 grid, overlay on 4th if more
  Widget _gridPreview(BuildContext context) {
    final bool hasMore = images.length > 4;
    final int showCount = hasMore ? 4 : images.length;

    return Stack(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: showCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final String url = images[index];
            final bool overlayMore = hasMore && index == 3;

            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () => onImageTap?.call(index),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _errorBox(),
                      loadingBuilder: (c, child, progress) =>
                          progress == null ? child : _loaderBox(),
                    ),
                  ),
                  if (overlayMore)
                    Material(
                      color: Colors.black45,
                      child: InkWell(
                        onTap: onViewMoreTap,
                        child: Center(
                          child: Text(
                            '+${images.length - 3} more',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
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
        _imageCountBadge(), // ✅ total images badge
      ],
    );
  }

  // Badge to show total number of images (bottom-right)
  Widget _imageCountBadge() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${images.length} photos',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _errorBox() => Container(
    color: Colors.grey[300],
    child: const Icon(Icons.broken_image, size: 40),
  );

  Widget _loaderBox() => Container(
    color: Colors.grey[200],
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );
}
