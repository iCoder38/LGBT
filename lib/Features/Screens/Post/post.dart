import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  File? _selectedImage;
  final Dio _dio = Dio();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _typeController = TextEditingController(
    text: "Image",
  ); // default "Image"

  // Image Picker
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Upload API Call
  Future<void> _uploadImage() async {
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );

    if (_titleController.text.isEmpty) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter post title')));
      return;
    }

    // ✅ MANDATORY IMAGE CHECK
    if (_selectedImage == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    String uploadUrl = BaseURL().baseUrl;

    try {
      final userData = await UserLocalStorage.getUserData();

      String fileName = _selectedImage!.path.split('/').last;

      FormData formData = FormData.fromMap({
        'image_1': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: fileName,
        ),
        'action': 'postadd',
        'userId': userData['userId'].toString(),
        'postTitle': _titleController.text.trim(),
        "postType": _typeController.text.trim(),
      });

      Response response = await _dio.post(uploadUrl, data: formData);

      GlobalUtils().customLog(response);

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (response.statusCode == 200) {
        GlobalUtils().customLog(response);
        if (data["status"] == "success") {
          String message = data["msg"] ?? "Upload successful!";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColor().GREEN),
          );
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
          String error = data["msg"] ?? "Upload failed.";
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      } else {
        GlobalUtils().customLog(response);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.statusMessage}')),
        );
      }
    } catch (e) {
      GlobalUtils().customLog(e);
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Localizer.get(AppText.dashboard.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.chevron_left,
        showBackButton: true,
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Post Title TextField
            CustomTextField(
              controller: _titleController,
              hintText: "Enter Post Title",
            ),

            const SizedBox(height: 16),

            // Post Type TextField (or use dropdown if needed)
            /*CustomTextField(
              controller: _typeController,
              hintText: "Enter Post Type (e.g. Image, Text, Video)",
            ),*/
            const SizedBox(height: 16),

            // Image Picker button
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),

            const SizedBox(height: 16),

            // Show image preview if selected
            if (_selectedImage != null)
              Center(
                child: Image.file(
                  _selectedImage!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 24),

            // Upload Button
            ElevatedButton(
              onPressed: _uploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor().GREEN,
              ),
              child: const Text('Upload Post'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    super.dispose();
  }
}
