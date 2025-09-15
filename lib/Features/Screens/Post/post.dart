import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:video_player/video_player.dart';
import 'package:mime/mime.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  File? _selectedImage;
  File? _selectedVideo;
  final Dio _dio = Dio();

  final TextEditingController _titleController = TextEditingController();
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _titleController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _selectedVideo = null;
        _videoController?.dispose();
        _videoController = null;
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedVideo = File(pickedFile.path);
        _selectedImage = null;

        _videoController?.dispose();
        _videoController = VideoPlayerController.file(_selectedVideo!)
          ..initialize().then((_) {
            setState(() {});
          });
      });
    }
  }

  Future<Response?> _uploadPost() async {
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );

    if (_titleController.text.isEmpty) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Enter What's in your mind.")),
      );
      return null;
    }

    final String uploadUrl = BaseURL().baseUrl;

    try {
      final userData = await UserLocalStorage.getUserData();
      final String finalPostType = _selectedVideo != null
          ? "Video"
          : _selectedImage != null
          ? "Image"
          : "Text";

      Response response;

      if (_selectedImage != null || _selectedVideo != null) {
        FormData formData = FormData();

        if (_selectedImage != null) {
          formData.files.add(
            MapEntry(
              'image_1',
              await MultipartFile.fromFile(
                _selectedImage!.path,
                filename: _selectedImage!.path.split('/').last,
              ),
            ),
          );
        }

        if (_selectedVideo != null) {
          final mimeType = lookupMimeType(_selectedVideo!.path) ?? 'video/mp4';

          GlobalUtils().customLog("📹 VIDEO PATH: ${_selectedVideo!.path}");
          GlobalUtils().customLog("📹 MIME TYPE: $mimeType");

          formData.files.add(
            MapEntry(
              'video',
              await MultipartFile.fromFile(
                _selectedVideo!.path,
                filename: _selectedVideo!.path.split('/').last,
                contentType: MediaType.parse(mimeType),
              ),
            ),
          );
        }

        final fields = [
          MapEntry('action', 'postadd'),
          MapEntry('userId', userData['userId'].toString()),
          MapEntry('postTitle', _titleController.text.trim()),
          MapEntry('postType', finalPostType),
        ];
        fields.forEach(
          (entry) =>
              GlobalUtils().customLog("📤 ${entry.key} = ${entry.value}"),
        );

        formData.fields.addAll(fields);

        response = await _dio.post(
          uploadUrl,
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
      } else {
        final Map<String, dynamic> body = {
          'action': 'postadd',
          'userId': userData['userId'].toString(),
          'postTitle': _titleController.text.trim(),
          'postType': finalPostType,
        };

        body.forEach((key, value) {
          GlobalUtils().customLog("📤 $key = $value");
        });

        response = await _dio.post(
          uploadUrl,
          data: body,
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );
      }

      Navigator.pop(context);

      GlobalUtils().customLog("📬 RESPONSE STATUS: ${response.statusCode}");
      GlobalUtils().customLog("📬 RESPONSE DATA: ${response.data}");

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (response.statusCode == 200 && data["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["msg"] ?? "Upload successful!"),
            backgroundColor: AppColor().GREEN,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["msg"] ?? "Upload failed.")),
        );
      }

      return response;
    } catch (e, stack) {
      Navigator.pop(context);
      GlobalUtils().customLog("❌ ERROR: $e");
      GlobalUtils().customLog("❌ STACK TRACE: $stack");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Localizer.get(AppText.post.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.chevron_left,
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _titleController,
              hintText: Localizer.get(AppText.enterPostTitle.key),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickImage,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload),
                        customText(
                          Localizer.get(AppText.uploadImage.key),
                          12,
                          context,
                        ),
                      ],
                    ),
                    // Text(Localizer.get(AppText.uploadImage.key)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickVideo,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload),
                        customText(
                          Localizer.get(AppText.uploadVideo.key),
                          12,
                          context,
                        ),
                      ],
                    ),
                    // Text(Localizer.get(AppText.uploadVideo.key)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null)
              Center(
                child: Image.file(
                  _selectedImage!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else if (_selectedVideo != null &&
                _videoController != null &&
                _videoController!.value.isInitialized)
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                    if (!_videoController!.value.isPlaying)
                      GestureDetector(
                        onTap: () {
                          _videoController!.play();
                          setState(() {});
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else if (_selectedVideo != null)
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 12),
            CustomButton(
              text: Localizer.get(AppText.publish.key),
              textColor: AppColor().kWhite,
              color: AppColor().kNavigationColor,
              onPressed: () {
                _uploadPost();
              },
            ),
          ],
        ),
      ),
    );
  }
}
