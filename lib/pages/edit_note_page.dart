// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:payment_app/common/common_methods.dart';
import 'package:payment_app/components/app_bar_components.dart';
import 'package:payment_app/components/dropdown_menu.dart';
import 'package:payment_app/database/dabase_handler.dart';
import 'package:payment_app/models/notes_models.dart';
import 'package:payment_app/pages/maps_page.dart';
import 'package:payment_app/preview/video_preview.dart';
import 'package:payment_app/widgets/forms_widget.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:printing/printing.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class EditNotePage extends StatefulWidget {
  NotesModel notesModel;
  final bool? isPaymentMade;
  final String? noteId;
  final String? userId;

  EditNotePage({
    super.key,
    required this.notesModel,
    this.isPaymentMade,
    this.noteId,
    this.userId,
  });

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  NotesModel? notes;
  late TextEditingController _titleController = TextEditingController();
  late TextEditingController _engTextController = TextEditingController();
  bool _isNoteEditing = false;
  double _progress = 0.7;
  PageController pageController = PageController();
  List<TextEditingController> _textControllers =
      List.generate(6, (index) => TextEditingController());
  final List<String> _localImagePaths = [];
  final List<String> _localVideoPaths = [];
  int? pinnedIndex;
  int? pinnedVideoIndex;
  List<VideoPlayerController?> videoControllers =
      List<VideoPlayerController?>.filled(6, null);
  List<TextEditingController> textControllers =
      List<TextEditingController>.generate(
    6,
    (_) => TextEditingController(),
  );

  List<File?> videos = List<File?>.filled(6, null);
  List<XFile?> images = [];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<AudioPlayer> audioPlayers = [];
  final List<String> recordingPaths = [];
  bool isPlaying = false;
  bool isRecording = false;
  String? selectedLocationName;
  List<bool> isPlayingList = [];
  List<Duration> currentPositionList = [];
  List<Duration> totalDurationList = [];
  List<double> playbackSpeedList = [];
  String? _selectedLocationName;
  List<TextEditingController> controllers = [];
  String selectedItem = 'My Notes';
  late Future<List<NotesModel>> _notes;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.notesModel.title);
    List<String> bodyParts = widget.notesModel.body.split('\n');

    _textControllers = bodyParts
        .map((bodyText) => TextEditingController(text: bodyText))
        .toList();
    super.initState();
    tz.initializeTimeZones();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _notes = fetchNotes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _engTextController.dispose();
    pageController.dispose();
    for (var controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<List<NotesModel>> _fetchAudioData() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('notes').get();
    return snapshot.docs.map((doc) => NotesModel.fromSnapshot(doc)).toList();
  }

  Future<String> uploadFileToFirebase(String filePath) async {
    File file = File(filePath);
    String fileName = path.basename(filePath);
    Reference ref = FirebaseStorage.instance.ref().child('uploads/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // Dummy file upload function - you need to implement the actual upload logic
  Future<String> _uploadFile(File file) async {
    String fileName = path.basename(file.path);
    Reference ref = FirebaseStorage.instance.ref().child('uploads/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _uploadAndSaveNote() async {
    setState(() {
      _isNoteEditing = true;
    });

    // Upload images
    List<String> uploadedImageUrls = [];
    for (String imagePath in _localImagePaths) {
      String uploadedImageUrl = await _uploadFile(File(imagePath));
      uploadedImageUrls.add(uploadedImageUrl);
    }

    // Upload videos (if needed)
    List<String> uploadedVideoUrls = [];
    for (String videoPath in _localVideoPaths) {
      String uploadedVideoUrl = await _uploadFile(File(videoPath));
      uploadedVideoUrls.add(uploadedVideoUrl);
    }

    // Update Firestore with the new URLs
    await DatabaseHandler.updateNote(
      NotesModel(
        id: widget.notesModel.id,
        title: _titleController.text,
        body: _engTextController.text,
        category: widget.notesModel.category,
        imageUrls: uploadedImageUrls,
        videoUrls: uploadedVideoUrls,
      ),
    );

    setState(() {
      _isNoteEditing = false;
    });

    Navigator.pop(context);
  }

  Future<void> _editNote() async {
    if (_titleController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Enter Title");
      return;
    }

    if (_engTextController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Try Something");
      return;
    }

    await _uploadAndSaveNote();
  }

  void _shareNote() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (_titleController.text.isNotEmpty)
                pw.Text("Title: ${_titleController.text}",
                    style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              if (_engTextController.text.isNotEmpty)
                pw.Text("Text: ${_engTextController.text}",
                    style: const pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              if (widget.notesModel.imageUrls != null &&
                  widget.notesModel.imageUrls!.isNotEmpty)
                pw.Text("Images:",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ...widget.notesModel.imageUrls!
                  .map((url) => pw.Text(url))
                  .toList(),
              pw.SizedBox(height: 20),
              if (widget.notesModel.videoUrls != null &&
                  widget.notesModel.videoUrls!.isNotEmpty)
                pw.Text("Videos:",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ...widget.notesModel.videoUrls!
                  .map((url) => pw.Text(url))
                  .toList(),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'note.pdf');
  }

  Future<void> _pickAudio() async {
    // Implement audio picker here
  }

  Widget _buildHeader() {
    String location = widget.notesModel.location ?? "No Location Available";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: AppbarButtons(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        SizedBox(
          width: 15.w,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (location.length > 20) {
                _showLocationDialog(location);
              }
            },
            child: Text(
              location,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        Row(
          children: [
            AppbarButtons(
              icon: _selectedLocationName != null
                  ? FluentIcons.location_48_filled
                  : FluentIcons.location_48_regular,
              onTap: () {
                _navigateAndSelectLocation();
              },
            ),
            const SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(right: 15.w),
              child: AppbarButtons(
                icon: (Icons.share),
                onTap: _shareNote,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showLocationDialog(String location) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Full Location'),
          content: Text(location),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, bool isAudio,
      {required Function onAdd}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
        isAudio
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.image_outlined),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: Colors.indigoAccent),
                    onPressed: () => onAdd(),
                  ),
                ],
              )
            : Container(),
      ],
    );
  }

  Future<void> _navigateAndSelectLocation() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const MapSample()),
    );

    if (result != null) {
      setState(() {
        selectedLocationName = result;
      });
    } else {}
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

  Future<List<NotesModel>> fetchNotes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User is not authenticated");
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .get();

    return snapshot.docs.map((doc) => NotesModel.fromSnapshot(doc)).toList();
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

  Widget imageItemBuilder(String filePath, int index) {
    return Stack(
      children: [
        Image.file(File(filePath), fit: BoxFit.cover),
      ],
    );
  }

  Widget _buildAudioGridView(List<MapEntry<String, String>> audioData) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (audioData.isNotEmpty)
            Column(
              children: [
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: audioData.asMap().entries.map((entry) {
                      int index = entry.key;

                      return GestureDetector(
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
                                        const Icon(
                                          Icons.play_arrow_rounded,
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
                                        value:
                                            0.0, // Placeholder for current position
                                        max:
                                            100.0, // Placeholder for total duration
                                        onChanged: (value) {
                                          // Handle seeking in the audio file
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
                                      "00:00", // Placeholder for total duration
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "1x", // Placeholder for playback speed
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
                        onLongPress: () {},
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          if (audioData.isEmpty)
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
          if (audioData.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: audioData.asMap().entries.map((entry) {
                int index = entry.key;
                String transcription = entry.value.value;
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

  List<MapEntry<String, String>> _prepareAudioData() {
    const placeholderText = 'No transcription available';

    List<String>? recordingUrls = widget.notesModel.recordingUrls;
    List<String>? transcriptions = widget.notesModel.transcriptions;

    if (recordingUrls == null || recordingUrls.isEmpty) {
      return [];
    }

    return recordingUrls.asMap().entries.map((entry) {
      int index = entry.key;
      String url = entry.value;
      String transcription =
          transcriptions != null && index < transcriptions.length
              ? transcriptions[index]
              : placeholderText;
      return MapEntry(url, transcription);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Colors.white,
      floatingActionButton: SizedBox(
        child: FittedBox(
          child: FloatingActionButton.extended(
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
            onPressed: _editNote,
            backgroundColor: Colors.indigoAccent,
          ),
        ),
      ),
      body: AbsorbPointer(
        absorbing: _isNoteEditing,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _isNoteEditing
                ? Center(
                    child: CircularPercentIndicator(
                      radius: 60.0,
                      lineWidth: 5.0,
                      percent: _progress,
                      center: Text(
                        "${(_progress * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(
                            color: Colors.indigoAccent, fontSize: 20),
                      ),
                      progressColor: Colors.indigoAccent,
                    ),
                  )
                : Container(),
            ListView(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 10),
                MyDropDownMenu(
                  onCategorySelected: (value) {
                    selectedItem = value;
                  },
                ),
                FormWidget(
                  maxLength: 20,
                  controller: _titleController,
                  hintText: "Title",
                  fontSize: 20,
                ),
                const SizedBox(height: 5),
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    reusableText('Gallery', false),
                                    reusableText('Camera', false),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                FutureBuilder<List<NotesModel>>(
                                  future: _notes,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Center(
                                          child: Text('No data found'));
                                    }

                                    final notes = snapshot.data!;

                                    return SizedBox(
                                      height: 600,
                                      child: ListView.builder(
                                        itemCount: notes.length,
                                        itemBuilder: (context, index) {
                                          final note = notes[index];

                                          return Column(
                                            children: [
                                              // Image display logic
                                              if (note.imageUrls != null &&
                                                  note.imageUrls!.isNotEmpty)
                                                Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons
                                                                  .image_outlined,
                                                              size: 30),
                                                          onPressed: () =>
                                                              _pickImage(
                                                                  ImageSource
                                                                      .gallery),
                                                        ),
                                                        Text(
                                                          "${note.imageUrls!.length}/3",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons
                                                                  .camera_alt_outlined,
                                                              size: 30),
                                                          onPressed: () =>
                                                              _pickImage(
                                                                  ImageSource
                                                                      .camera),
                                                        ),
                                                      ],
                                                    ),
                                                    SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Row(
                                                        children: List.generate(
                                                            note.imageUrls!
                                                                .length, (i) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 5),
                                                            child:
                                                                buildImageWithTextField(
                                                              note.imageUrls![
                                                                  i],
                                                              TextEditingController(), // Add your controllers logic here
                                                              i,
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              const Divider(
                                                  thickness: 1,
                                                  color: Colors.grey),

                                              // Video upload icons
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons
                                                            .ondemand_video_rounded,
                                                        size: 30),
                                                    onPressed: () {
                                                      // Add your video picker logic for gallery here
                                                    },
                                                  ),
                                                  Text(
                                                    "${note.videoUrls?.length ?? 0}/3",
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.videocam,
                                                        size: 30),
                                                    onPressed: () {
                                                      // Add your video picker logic for camera here
                                                    },
                                                  ),
                                                ],
                                              ),

                                              // Video display logic
                                              if (note.videoUrls != null &&
                                                  note.videoUrls!.isNotEmpty)
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    children: List.generate(
                                                        note.videoUrls!.length,
                                                        (i) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 5),
                                                        child:
                                                            buildVideoWithTextField(
                                                          VideoPlayerController
                                                              .network(note
                                                                  .videoUrls![i]),
                                                          TextEditingController(),
                                                          i,
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),

                                // The rest of the UI elements
                                const Divider(thickness: 1, color: Colors.grey),
                                const SizedBox(height: 5),
                                _buildSectionTitle(
                                  "Audio",
                                  false,
                                  onAdd: _pickAudio,
                                ),
                                _buildAudioGridView(
                                  _prepareAudioData(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  void nextPage() {
    if (pageController.page!.toInt() < _textControllers.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

  Widget buildImageWithTextField(
      String imageUrl, TextEditingController controller, int index) {
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(
        context,
        () {
          setState(() {
            // Remove image logic
          });
          Navigator.of(context).pop();
        },
        () {
          // Handle pinning action
          Navigator.of(context).pop();
        },
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Navigate to photo preview
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 160,
                width: 140,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, size: 140),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              width: 140,
              child: TextField(
                maxLength: 20,
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Tag",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVideoWithTextField(VideoPlayerController controller,
      TextEditingController textController, int index) {
    return controller.value.isInitialized
        ? GestureDetector(
            onLongPress: () => _showDeleteDialog(
              context,
              () {
                setState(() {
                  // Remove video logic
                });
                Navigator.of(context).pop();
              },
              () {
                // Pin video logic
                Navigator.of(context).pop();
              },
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(controller),
                    const Center(
                      child:
                          Icon(Icons.play_arrow, color: Colors.white, size: 60),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    width: 140,
                    child: TextField(
                      controller: textController,
                      maxLength: 20,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Tag",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : const CircularProgressIndicator();
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
}
