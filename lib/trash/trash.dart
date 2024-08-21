 // Function to pick image from gallery
  /* Future<void> _pickImageFromGallery() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          /*  if (image == null) {
            image = pickedImage;
          } else if (image2 == null) {
            image2 = pickedImage;
          } else if (image3 == null) {
            image3 = pickedImage;
          } else if (image4 == null) {
            image4 = pickedImage;
          } else if (image5 == null) {
            image5 = pickedImage;
          } */
        });
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
    }
  } */

  // Function to pick image from camera
  /* Future<void> pickImage(int index, ImageSource source) async {
    if (totalItems < 10) {
      final picture = await ImagePicker().pickImage(source: source);
      if (picture != null) {
        setState(() {
          images[index] = picture;
          totalItems++;
        });
      }
    }
  } */

  /* Future<String?> pickVideo(ImageSource source) async {
    final video = await ImagePicker().pickVideo(source: source);
    return video?.path;
  }

  Future<String> _uploadVideo(XFile video) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage
          .ref()
          .child("notes_videos/${DateTime.now().millisecondsSinceEpoch}.mp4");

      UploadTask uploadTask = ref.putFile(File(video.path));
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      return '';
    }
  } */

  /* Future<void> _pickVideo(int index, ImageSource source) async {
    final pickedVideo = await ImagePicker()
        .pickVideo(source: source, maxDuration: const Duration(seconds: 10));
    if (pickedVideo != null) {
      setState(() {
        videos[index] = pickedVideo;
        _initializeVideoPlayer(index);
      });
      String url = await _uploadVideo(pickedVideo);
      setState(() {
        videoURLs[index] = url;
      });
    }
  } */

/*  void _initializeVideoPlayer(int index) {
    VideoPlayerController controller =
        VideoPlayerController.file(File(videos[index]!.path));
    videoControllers[index] = controller;
    controller.initialize().then((_) {
      setState(() {});
      controller.play();
    });
  } */

 /* Widget _videoPlayerPreview(
      VideoPlayerController? controller, String? videoUrl) {
    if (controller != null && videoUrl != null) {
      return GestureDetector(
        onTap: () => _navigateToPreview(videoUrl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 160,
            width: 140,
            child: VideoPlayer(controller),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  } */

 // List<XFile?> videos = [null, null, null, null, null];
  /* List<VideoPlayerController?> videoControllers = [
    null,
    null,
    null,
    null,
    null
  ]; */

  
  // final List<XFile?> images = List<XFile?>.filled(5, null);
  // final List<TextEditingController> controllers =
  // List<TextEditingController>.generate(5, (_) => TextEditingController());