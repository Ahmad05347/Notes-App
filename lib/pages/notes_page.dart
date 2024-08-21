// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:payment_app/common/common_methods.dart';
import 'package:payment_app/components/app_bar_components.dart';
import 'package:payment_app/components/dropdown_menu.dart';
import 'package:payment_app/localization/locals.dart';
import 'package:payment_app/models/notes_models.dart';
import 'package:payment_app/pages/maps_page.dart';
import 'package:payment_app/preview/photos_preview.dart';
import 'package:payment_app/preview/video_preview.dart';
import 'package:payment_app/widgets/forms_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:video_player/video_player.dart';

class NotesPage extends StatefulWidget {
  final bool? isPaymentMade;
  const NotesPage({
    super.key,
    this.isPaymentMade,
  });

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String? _selectedLocationName;
  final AudioPlayer audioPlayer = AudioPlayer();
  final List<String> recordingPaths = [];
  bool isPlaying = false;
  bool isRecording = false;
  double playbackSpeed = 1.0;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  final List<TextEditingController> _textControllers =
      List.generate(6, (index) => TextEditingController());
  final TextEditingController _titleController = TextEditingController();

  VideoPlayerController? _videoPlayerController;
  Duration duration = const Duration();
  Duration position = const Duration();

  final int maxRecordings = 6;
  final AudioRecorder audioRecorder = AudioRecorder();
  final PageController pageController = PageController();

  final TextEditingController _taskController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isNoteCreating = false;
  String selectedItem = 'My Notes';
  double progressValue = 0;

  List<String?> videoURLs = [null, null, null, null, null];
  List<XFile?> images = [];
  List<TextEditingController> controllers = [];
  List<File?> videos = List<File?>.filled(6, null);
  List<VideoPlayerController?> videoControllers =
      List<VideoPlayerController?>.filled(6, null);
  List<TextEditingController> textControllers =
      List<TextEditingController>.generate(
    6,
    (_) => TextEditingController(),
  );
  int? pinnedIndex;
  int? pinnedVideoIndex;
  List<AudioPlayer> audioPlayers = [];
  List<bool> isPlayingList = [];
  List<Duration> currentPositionList = [];
  List<Duration> totalDurationList = [];
  List<double> playbackSpeedList = [];
  List<String> transcriptions = [];

  final SpeechToText speechToText = SpeechToText();

  @override
  void dispose() {
    // Dispose audio player
    audioPlayer.dispose();

    // Dispose each video controller
    for (var controller in videoControllers) {
      controller?.dispose();
    }

    // Dispose each text controller
    for (var controller in _textControllers) {
      controller.dispose();
    }
    for (var player in audioPlayers) {
      player.dispose();
    }

    // Dispose page controller
    pageController.dispose();

    // Dispose video player controller
    _videoPlayerController?.dispose();

    // Dispose title controller
    _titleController.dispose();

    // Dispose task controller
    _taskController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    createNotificationChannel();
    _initializeSpeechToText();
  }

  void _initializeSpeechToText() async {
    bool available = await speechToText.initialize();
    if (!available) {
      Fluttertoast.showToast(msg: "Speech recognition not available");
    }
  }

  Future<void> _navigateAndSelectLocation() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const MapSample()),
    );

    if (result != null) {
      setState(() {
        _selectedLocationName = result;
      });
    } else {}
  }

  void _initializePlayers() {
    // Initialize lists based on the number of recordings
    for (int i = 0; i < recordingPaths.length; i++) {
      audioPlayers.add(AudioPlayer());
      isPlayingList.add(false);
      currentPositionList.add(Duration.zero);
      totalDurationList.add(Duration.zero);
      playbackSpeedList.add(1.0);

      _setupAudioPlayer(i);
    }
  }

  void _setupAudioPlayer(int index) {
    audioPlayers[index].positionStream.listen((position) {
      setState(() {
        currentPositionList[index] = position;
      });
    });

    audioPlayers[index].durationStream.listen((duration) {
      setState(() {
        totalDurationList[index] = duration ?? Duration.zero;
      });
    });

    audioPlayers[index].playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          isPlayingList[index] = false;
          currentPositionList[index] = Duration.zero;
        });
      }
    });
  }

  void _changeSpeed(int index) {
    setState(() {
      playbackSpeedList[index] = playbackSpeedList[index] == 1.0 ? 1.5 : 1.0;
      audioPlayers[index].setSpeed(playbackSpeedList[index]);
    });
  }

  void _togglePlayPause(int index) async {
    if (isPlayingList[index]) {
      await audioPlayers[index].stop();
      setState(() {
        isPlayingList[index] = false;
      });
    } else {
      await audioPlayers[index].setFilePath(recordingPaths[index]);
      await audioPlayers[index].play();
      setState(() {
        isPlayingList[index] = true;
      });
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // Function to get the current user's ID
  String? getCurrentUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<String> _uploadImageToFirebase(XFile image) async {
    String? userId = getCurrentUserId();
    if (userId == null) throw Exception("User not authenticated");

    String fileName = path.basename(image.path);
    Reference storageRef =
        FirebaseStorage.instance.ref().child('users/$userId/images/$fileName');
    UploadTask uploadTask = storageRef.putFile(File(image.path));

    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<String> _uploadRecordingToFirebase(String filePath) async {
    String? userId = getCurrentUserId();
    if (userId == null) throw Exception("User not authenticated");

    String fileName = path.basename(filePath);
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('users/$userId/recordings/$fileName');
    UploadTask uploadTask = storageRef.putFile(File(filePath));

    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<String> _uploadVideoToFirebase(File videoFile) async {
    String? userId = getCurrentUserId();
    if (userId == null) throw Exception("User not authenticated");

    String fileName = path.basename(videoFile.path);
    Reference storageRef =
        FirebaseStorage.instance.ref().child('users/$userId/videos/$fileName');
    UploadTask uploadTask = storageRef.putFile(videoFile);

    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<void> _createNote() async {
    String? userId = getCurrentUserId();
    if (userId == null) {
      Fluttertoast.showToast(msg: "User not authenticated");
      return;
    }

    if (_titleController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Enter Title");
      return;
    }

    if (_textControllers.isEmpty) {
      Fluttertoast.showToast(msg: "Try Something");
      return;
    }

    final String concatenatedText =
        _textControllers.map((controller) => controller.text).join("\n");

    List<Future<String>> videoUploadFutures = [];
    List<Future<String>> imageUploadFutures = [];
    List<Future<String>> recordingUploadFutures = [];

    List<String> videoTags = [];
    List<String> imageTags = [];
    List<String> recordingTags = [];
    List<String> savedTranscriptions = [];

    for (int i = 0; i < videos.length; i++) {
      if (videos[i] != null) {
        videoUploadFutures.add(_uploadVideoToFirebase(videos[i]!));
        videoTags.add(_textControllers[i].text);
      }
    }

    for (int i = 0; i < images.length; i++) {
      if (images[i] != null) {
        imageUploadFutures.add(_uploadImageToFirebase(images[i]!));
        imageTags.add(_textControllers[i].text);
      }
    }

    for (int i = 0; i < recordingPaths.length; i++) {
      if (recordingPaths[i].isNotEmpty) {
        recordingUploadFutures
            .add(_uploadRecordingToFirebase(recordingPaths[i]));
        recordingTags.add("Recording ${i + 1}");
        savedTranscriptions.add(transcriptions[i]);
      }
    }

    try {
      List<String> videoUrls = await Future.wait(videoUploadFutures);
      List<String> imageUrls = await Future.wait(imageUploadFutures);
      List<String> recordingUrls = await Future.wait(recordingUploadFutures);

      final note = NotesModel(
        title: _titleController.text,
        body: concatenatedText,
        videoUrls: videoUrls,
        imageUrls: imageUrls,
        recordingUrls: recordingUrls,
        videoTags: videoTags,
        imageTags: imageTags,
        recordingTags: recordingTags,
        transcriptions: savedTranscriptions,
        category: selectedItem,
        location: _selectedLocationName,
        createdAt: Timestamp.now(),
      );

      WriteBatch batch = FirebaseFirestore.instance.batch();
      DocumentReference noteRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc();

      batch.set(noteRef, note.toDocument());
      await batch.commit();

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Error creating note: $error");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    int maxFreeImages = 3;
    bool isPaymentMade = widget.isPaymentMade ?? false;
    int maxImages = isPaymentMade ? 6 : maxFreeImages;

    if (images.length >= maxImages) {
      if (!isPaymentMade && images.length >= maxFreeImages) {
        showUpgradeDialog();
      }
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        images.add(image);
        controllers.add(TextEditingController());
      });
    }
  }

  Future<void> _pickVideo(int index, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: source);
    if (video != null) {
      File videoFile = File(video.path);
      setState(() {
        videos[index] = videoFile;
      });
      _initializeVideoPlayer(index);
    }
  }

  void _initializeVideoPlayer(int index) {
    VideoPlayerController controller =
        VideoPlayerController.file(File(videos[index]!.path));
    controller.initialize().then((_) {
      setState(() {
        videoControllers[index] = controller;
        controller.play();
      });
    });
  }

  Widget _videoPlayerPreview(
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
  }

  void _navigateToPreview(String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPreview(videoUrl: videoUrl),
      ),
    );
  }

  Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id', // id
      'your_channel_name', // title
      importance: Importance.max,
      playSound: true,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isGranted) {
      // The permission is granted, proceed with your notifications.
    } else {
      // Request the permission.
      if (await Permission.scheduleExactAlarm.request().isGranted) {
        // The permission is granted, proceed with your notifications.
      } else {
        // Handle the case when the permission is not granted.
      }
    }
  }

  Future<void> scheduleNotification(
      String taskTitle, String noteId, DateTime scheduledDateTime) async {
    await _requestExactAlarmPermission();

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Task Reminder',
      taskTitle,
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      platformChannelSpecifics,
      // ignore: deprecated_member_use
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: noteId, // Include note ID as payload
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 8, minute: 30),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void nextPage() {
    if (pageController.page!.toInt() < _textControllers.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void showUpgradeDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: AlertDialog(
            backgroundColor: Colors.indigo,
            title: const Text(
              'Upgrade to Premium',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'You have reached the free limit of 3 images. Upgrade to the premium package to add more images.',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement upgrade logic here
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  backgroundColor: Colors.white, // Text color
                ),
                child: const Text('Upgrade'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    void showNoteStatus() {
      showMaterialModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        elevation: 30,
        builder: (_) => Wrap(
          children: [
            _isNoteCreating ? const CircularProgressIndicator() : Container(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 20),
                  buildRow(Icons.text_fields_rounded,
                      _titleController.text.isNotEmpty, "Title"),
                  const SizedBox(height: 10),
                  buildRow(FluentIcons.notebook_32_regular,
                      _textControllers.isNotEmpty, "Points"),
                  const SizedBox(height: 10),
                  buildRow(Icons.image_outlined, images.isNotEmpty, "Images"),
                  const SizedBox(height: 10),
                  buildRow(Icons.ondemand_video_outlined,
                      videos.any((video) => video != null), "Video"),
                  const SizedBox(height: 10),
                  buildRow(Icons.mic, recordingPaths.isNotEmpty, "Recordings"),
                  const SizedBox(height: 10),
                  buildRow(FluentIcons.location_48_regular,
                      _selectedLocationName != null, "Location"),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildButton(
                          context, 'Back', Colors.grey.shade300, Colors.black,
                          () {
                        Navigator.pop(context);
                      }),
                      buildButton(
                        context,
                        'Save',
                        Colors.indigo,
                        Colors.white,
                        () async {
                          if (mounted) {
                            setState(() {
                              _isNoteCreating = true;
                            });
                          }

                          try {
                            await _createNote();
                          } catch (e) {
                            Fluttertoast.showToast(msg: "Error: $e");
                          } finally {
                            if (mounted) {
                              if (!_isNoteCreating) {
                                Navigator.pop(context);
                              }
                              setState(() {
                                _isNoteCreating = false;
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    void showTaskModal(BuildContext context) {
      showModalBottomSheet<dynamic>(
        backgroundColor: Colors.white,
        elevation: 10,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        isScrollControlled: true, // Allow the modal to be scrollable
        builder: (_) => DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) => Padding(
            padding:
                const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 20),
            child: SingleChildScrollView(
              controller: controller,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    maxLines: 2,
                    keyboardType: TextInputType.text,
                    controller: _taskController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Task',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                    ),
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: Text(
                      "Date: ${DateFormat.yMMMMd().format(_selectedDate)}",
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      selectDate(context);
                    },
                  ),
                  ListTile(
                    title: Text(
                      "Time: ${_selectedTime.format(context)}",
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      selectTime(context);
                    },
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      DateTime selectedDateTime = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _selectedTime.hour,
                        _selectedTime.minute,
                      );

                      if (_taskController.text.isNotEmpty) {
                        String noteId = 'some-note-id';
                        scheduleNotification(
                            _taskController.text, noteId, selectedDateTime);
                        _taskController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Task Scheduled on ${DateFormat.yMMMMd().format(selectedDateTime)} at ${TimeOfDay.fromDateTime(selectedDateTime).format(context)}',
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.indigoAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          "Done",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        label: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 10,
            ),
            Text(""),
            SizedBox(
              width: 15,
            ),
            Text(""),
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.check,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(""),
            SizedBox(
              width: 15,
            ),
            Text(""),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        onPressed: showNoteStatus,
        backgroundColor: Colors.indigoAccent,
      ),
      body: AbsorbPointer(
        absorbing: _isNoteCreating,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListView(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: AppbarButtons(
                        icon: Icons.arrow_back_ios_rounded,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: _selectedLocationName != null ? 190 : 140,
                          child: Text(
                            _selectedLocationName != null
                                ? '$_selectedLocationName'
                                : 'No location selected',
                            style: GoogleFonts.aBeeZee(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        AppbarButtons(
                          icon: _selectedLocationName != null
                              ? FluentIcons.location_48_filled
                              : FluentIcons.location_48_regular,
                          onTap: () {
                            _navigateAndSelectLocation();
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        AppbarButtons(
                          icon: FluentIcons.calendar_32_regular,
                          onTap: () => showTaskModal(
                            context,
                          ),
                        ),
                        const SizedBox(width: 15),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 10),
                    MyDropDownMenu(
                      onCategorySelected: (value) {
                        selectedItem = value;
                      },
                    ),
                    FormWidget(
                      isIcon: false,
                      maxLength: 20,
                      controller: _titleController,
                      hintText: LocalData.noteTitle.getString(context),
                      fontSize: 20,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PageView(
                            controller: pageController,
                            children: List.generate(
                              6,
                              (index) {
                                return FormWidget(
                                  isIcon: true,
                                  maxLength: 120,
                                  controller: _textControllers[index],
                                  hintText: "Point",
                                  maxLines: 6,
                                  fontSize: 20,
                                  onAdd: nextPage,
                                );
                              },
                            ),
                            onPageChanged: (index) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SmoothPageIndicator(
                      controller: pageController,
                      count: 6,
                      effect: ScrollingDotsEffect(
                        activeDotColor: Colors.indigoAccent,
                        dotColor: Colors.grey.shade300,
                      ),
                      axisDirection: Axis.horizontal,
                      onDotClicked: (index) {
                        pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              reusableText('Gallery', false),
                              reusableText('Camera', false),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.image_outlined,
                                        size: 30),
                                    onPressed: () =>
                                        _pickImage(ImageSource.gallery),
                                  ),
                                  Text(
                                    "${images.where((image) => image != null).length}/3",
                                    style: GoogleFonts.poppins(fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.camera_alt_outlined,
                                        size: 30),
                                    onPressed: () =>
                                        _pickImage(ImageSource.camera),
                                  ),
                                ],
                              ),
                              if (images.any((image) => image != null))
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children:
                                        List.generate(images.length, (index) {
                                      if (images[index] != null) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5),
                                          child: buildImageWithTextField(
                                            images[index],
                                            controllers[index],
                                            index,
                                          ),
                                        );
                                      } else {
                                        return const SizedBox();
                                      }
                                    }),
                                  ),
                                ),
                            ],
                          ),
                          const Divider(thickness: 1, color: Colors.grey),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.ondemand_video_rounded,
                                        size: 30),
                                    onPressed: () {
                                      for (int i = 0; i < videos.length; i++) {
                                        if (videos[i] == null) {
                                          _pickVideo(i, ImageSource.gallery);
                                          break;
                                        }
                                      }
                                    },
                                  ),
                                  Text(
                                    "${videos.where((video) => video != null).length}/3",
                                    style: GoogleFonts.poppins(fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.videocam, size: 30),
                                    onPressed: () {
                                      for (int i = 0; i < videos.length; i++) {
                                        if (videos[i] == null) {
                                          _pickVideo(i, ImageSource.camera);
                                          break;
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                              if (videos.any((video) => video != null))
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children:
                                        List.generate(videos.length, (index) {
                                      if (videos[index] != null) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5),
                                          child: buildVideoWithTextField(
                                              videoControllers[index],
                                              textControllers[index],
                                              index),
                                        );
                                      } else {
                                        return const SizedBox();
                                      }
                                    }),
                                  ),
                                ),
                            ],
                          ),
                          const Divider(thickness: 1, color: Colors.grey),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 15,
                        left: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Audio",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: Text(
                              "${recordingPaths.length}/3",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _recordingButton(),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        buildUI(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVideoWithTextField(VideoPlayerController? controller,
      TextEditingController videoTagController, int index) {
    final FocusNode focusNode = FocusNode();

    return GestureDetector(
      onLongPress: () => _showDeleteDialog(context, () {
        setState(() {
          videos.removeAt(index);
          videoControllers[index]?.dispose();
          videoControllers.removeAt(index);
          // ignore: collection_methods_unrelated_type
          textControllers.remove(index);
          if (pinnedVideoIndex == index) {
            pinnedVideoIndex = null;
          } else if (pinnedVideoIndex != null && pinnedVideoIndex! > index) {
            pinnedVideoIndex = pinnedVideoIndex! - 1;
          }
        });
        Navigator.of(context).pop();
      }, () {
        setState(() {
          pinnedVideoIndex = index;
        });
        Navigator.of(context).pop();
      }),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              _videoPlayerPreview(controller, videos[index]?.path),
              if (controller != null)
                const Center(
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              if (pinnedVideoIndex == index)
                const Positioned(
                  top: 8,
                  left: 8,
                  child: Icon(
                    FontAwesomeIcons.mapPin,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              width: 140,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return TextField(
                    controller: videoTagController,
                    focusNode: focusNode,
                    maxLength: 20,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Tag",
                      counterText: focusNode.hasFocus ? null : '',
                    ),
                    onTap: () {
                      setState(() {});
                    },
                    onChanged: (text) {
                      if (!focusNode.hasFocus) {
                        setState(() {});
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImageWithTextField(
      XFile? image, TextEditingController imageTagController, int index) {
    if (image == null) {
      return Container();
    }

    final FocusNode focusNode = FocusNode();

    return GestureDetector(
      onLongPress: () => _showDeleteDialog(context, () {
        setState(() {
          images.removeAt(index);
          if (pinnedIndex == index) {
            pinnedIndex = null;
          } else if (pinnedIndex != null && pinnedIndex! > index) {
            pinnedIndex = pinnedIndex! - 1;
          }
        });
        Navigator.of(context).pop();
      }, () {
        setState(() {
          pinnedIndex = index;
        });
        Navigator.of(context).pop();
      }),
      child: Stack(
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoPreviewScreen(
                        imagePath: image.path,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(image.path),
                    height: 160,
                    width: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: 140,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return TextField(
                        maxLength: 20,
                        controller: imageTagController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          hintText: "Tag",
                          counterText: focusNode.hasFocus ? null : '',
                        ),
                        onTap: () {
                          setState(() {});
                        },
                        onChanged: (text) {
                          if (!focusNode.hasFocus) {
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (pinnedIndex == index)
            const Positioned(
              top: 8,
              left: 8,
              child: Icon(
                FontAwesomeIcons.mapPin,
                color: Colors.white,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, VoidCallback onDelete, VoidCallback onPin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: onPin,
                  icon: const Icon(
                    FluentIcons.pin_24_regular,
                    color: Colors.blue,
                    size: 38,
                  ),
                  tooltip: 'Pin',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    FluentIcons.delete_24_regular,
                    color: Colors.red,
                    size: 38,
                  ),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 60.0, vertical: 200.0),
          content: Text(
            "Select",
            style: GoogleFonts.poppins(fontSize: 23, color: Colors.grey[700]),
          ),
        );
      },
    );
  }

  Widget buildUI() {
    _initializePlayers();
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (recordingPaths.isNotEmpty)
            Column(
              children: [
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: recordingPaths.asMap().entries.map((entry) {
                      int index = entry.key;

                      return GestureDetector(
                        onLongPress: () {
                          _showDeleteDialog(
                            context,
                            () {
                              setState(() {
                                audioPlayers[index].stop();
                                audioPlayers[index].dispose();
                                recordingPaths.removeAt(index);
                                audioPlayers.removeAt(index);
                                isPlayingList.removeAt(index);
                                currentPositionList.removeAt(index);
                                totalDurationList.removeAt(index);
                                playbackSpeedList.removeAt(index);
                                transcriptions.removeAt(
                                    index); // Remove corresponding transcription
                              });
                              Navigator.of(context).pop();
                              Fluttertoast.showToast(msg: "Recording deleted");
                            },
                            () {
                              Navigator.of(context).pop();
                              Fluttertoast.showToast(msg: "Recording pinned");
                            },
                          );
                        },
                        child: MaterialButton(
                          onPressed: () => _togglePlayPause(index),
                          child: Container(
                            width: 150,
                            height: 100,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isPlayingList[index]
                                              ? Icons.stop
                                              : Icons.play_arrow_rounded,
                                          color: Colors.indigoAccent,
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () => _changeSpeed(index),
                                          child: Text(
                                            "Track ${index + 1}",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Slider(
                                        activeColor: Colors.indigoAccent,
                                        value: currentPositionList[index]
                                            .inSeconds
                                            .toDouble(),
                                        max: totalDurationList[index]
                                            .inSeconds
                                            .toDouble(),
                                        onChanged: (value) {
                                          audioPlayers[index].seek(
                                              Duration(seconds: value.toInt()));
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatDuration(totalDurationList[index]),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "${playbackSpeedList[index].toInt()}x",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          if (recordingPaths.isEmpty)
            Text(
              "",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 20),
          // Display the transcriptions
          if (transcriptions.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: transcriptions.asMap().entries.map((entry) {
                int index = entry.key;
                String transcription = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Text(
                    "Transcription ${index + 1}: $transcription",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // Modify your _recordingButton to include live speech-to-text
  Widget _recordingButton() {
    return GestureDetector(
      onTap: () async {
        if (isRecording) {
          String? filePath = await audioRecorder.stop();
          if (filePath != null) {
            setState(() {
              isRecording = false;
              if (recordingPaths.length < maxRecordings) {
                recordingPaths.add(filePath);
              } else {
                recordingPaths.removeAt(0); // Remove the oldest recording
                recordingPaths.add(filePath);
              }
            });
          }
          // Stop the speech-to-text listener after recording is stopped
          speechToText.stop();
        } else {
          if (await audioRecorder.hasPermission()) {
            final Directory appDocumentsDir =
                await getApplicationDocumentsDirectory();
            final String filePath = path.join(appDocumentsDir.path,
                "recording_${recordingPaths.length + 1}.wav");
            await audioRecorder.start(const RecordConfig(), path: filePath);
            setState(() {
              isRecording = true;
            });

            // Start speech-to-text listening while recording
            _convertSpeechToText();
          }
        }
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 5),
        decoration: const BoxDecoration(
          color: Colors.indigoAccent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
        ),
      ),
    );
  }

// Modify the _convertSpeechToText function to work with live microphone input
  void _convertSpeechToText() async {
    final SpeechToText speechToText = SpeechToText();
    bool available = await speechToText.initialize();
    if (available) {
      speechToText.listen(
        onResult: (result) {
          setState(() {
            transcriptions.add(result.recognizedWords);
          });
        },
        listenFor: const Duration(seconds: 30),
        // ignore: deprecated_member_use
        cancelOnError: true,
      );
    } else {
      // Handle the case when speech recognition is not available
      Fluttertoast.showToast(msg: "Speech recognition not available");
    }
  }
}
