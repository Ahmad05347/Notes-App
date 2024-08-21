import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class CommonAddPhotosVideos extends StatelessWidget {
  final Function(XFile) onImageSelected;
  final Function(XFile) onVideoSelected;

  CommonAddPhotosVideos({super.key, 
    required this.onImageSelected,
    required this.onVideoSelected,
  });

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onImageSelected(pickedFile);
    } else {
      Fluttertoast.showToast(msg: "No image selected.");
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    final XFile? pickedFile =
        await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      onVideoSelected(pickedFile);
    } else {
      Fluttertoast.showToast(msg: "No video selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.photo),
          label: const Text("Add Photo"),
          onPressed: () => _pickImage(context),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.videocam),
          label: const Text("Add Video"),
          onPressed: () => _pickVideo(context),
        ),
      ],
    );
  }
}
