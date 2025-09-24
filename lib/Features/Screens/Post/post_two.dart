import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

/// Message + Image screen with Firebase Firestore + Storage integration.
/// - Saves documents in a collection called `feeds` (you can change this)
/// - Document fields: userId, type (Text/Image/Video), message, imageUrls, createdAt
/// - Images uploaded to: "<userId>/FeedsImages/<timestamp>_index.jpg"
///
/// Make sure you have initialized Firebase in your app (Firebase.initializeApp()) and
/// added these packages to pubspec.yaml:
///   cloud_firestore
///   firebase_storage
///   firebase_auth
///   image_picker

class MessageImageScreen extends StatefulWidget {
  const MessageImageScreen({Key? key}) : super(key: key);

  @override
  State<MessageImageScreen> createState() => _MessageImageScreenState();
}

class _MessageImageScreenState extends State<MessageImageScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final int _maxImages = 5;
  final int _maxChars = 250;
  List<XFile> _images = [];
  bool _submitting = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? picked = await _picker.pickMultiImage();
      if (picked == null) return;
      final List<XFile> combined = List<XFile>.from(_images);
      for (final XFile f in picked) {
        if (combined.length >= _maxImages) break;
        if (!combined.any((e) => e.path == f.path)) combined.add(f);
      }
      setState(() => _images = combined);
    } catch (e) {
      debugPrint('Error picking images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not pick images. Make sure permissions are granted.',
          ),
        ),
      );
    }
  }

  Future<void> _pickImagesWithLimit() async {
    try {
      final List<XFile>? picked = await _picker.pickMultiImage();
      if (picked == null) return;
      final int remaining = _maxImages - _images.length;
      final List<XFile> toAdd = [];
      for (final XFile f in picked) {
        if (toAdd.length >= remaining) break;
        if (!_images.any((e) => e.path == f.path) &&
            !toAdd.any((e) => e.path == f.path)) {
          toAdd.add(f);
        }
      }
      setState(() => _images = [..._images, ...toAdd]);
    } catch (e) {
      debugPrint('Error picking images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not pick images. Make sure permissions are granted.',
          ),
        ),
      );
    }
  }

  void _removeImageAt(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages(String userId) async {
    // Upload all images and return list of download URLs
    final List<String> urls = [];
    for (int i = 0; i < _images.length; i++) {
      final XFile file = _images[i];
      final File localFile = File(file.path);
      final String filename = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final Reference ref = _storage.ref().child(
        '$userId/FeedsImages/$filename',
      );
      final UploadTask task = ref.putFile(localFile);

      final TaskSnapshot snap = await task.whenComplete(() {});
      final String url = await snap.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _submit() async {
    final String message = _controller.text.trim();

    if (message.isEmpty && _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message or add at least one image.'),
        ),
      );
      return;
    }

    final User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not signed in.')));
      return;
    }

    setState(() => _submitting = true);

    try {
      // Upload images if any
      List<String> imageUrls = [];
      if (_images.isNotEmpty) {
        imageUrls = await _uploadImages(user.uid);
      }

      // Determine type
      String type = 'Text';
      if (_images.isNotEmpty) type = 'Image';

      // Document structure — change collection name if you want
      final doc = {
        'userId': user.uid,
        'type': type,
        'message': message.isEmpty ? null : message,
        'imageUrls': imageUrls.isEmpty ? null : imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('LGBT_TOGO_PLUS/FEEDS/LIST').add(doc);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Submitted successfully')));

      // Clear UI
      setState(() {
        _controller.clear();
        _images = [];
      });
    } catch (e, st) {
      debugPrint('Submit error: $e$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Submission failed')));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canAddMore = _images.length < _maxImages;

    return Scaffold(
      appBar: AppBar(title: const Text('New Post'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Message input with larger field
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _controller,
                        maxLength: _maxChars,
                        maxLines: 6,
                        minLines: 4,
                        decoration: const InputDecoration(
                          hintText: "What's in your mind ?",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => setState(() {}),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: customText(
                              'Share your thoughts, ideas, or updates below.',
                              12,
                              context,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Vertical grid-style image picker
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: canAddMore ? _images.length + 1 : _images.length,
                  itemBuilder: (context, index) {
                    final bool isAddTile =
                        canAddMore && index == _images.length;
                    if (isAddTile) {
                      return GestureDetector(
                        onTap: _pickImagesWithLimit,
                        child: const DottedAddTile(remaining: 0),
                      );
                    }

                    final XFile img = _images[index];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(img.path),
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _removeImageAt(index),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DottedAddTile extends StatelessWidget {
  final int remaining;
  const DottedAddTile({Key? key, required this.remaining}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey),
      ),
    );
  }
}
