import 'package:flutter/material.dart';

class FullImageViewScreen extends StatelessWidget {
  final String imageUrl;

  const FullImageViewScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // light gray background
      body: SafeArea(
        child: Stack(
          children: [
            // Zoomable network image
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                panEnabled: true,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text("Failed to load image"));
                  },
                ),
              ),
            ),

            // Close (X) button
            Positioned(
              top: 16,
              right: 16,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
