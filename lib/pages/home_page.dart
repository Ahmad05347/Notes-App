import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:payment_app/components/my_button.dart';
import 'package:payment_app/components/my_drawer.dart';
import 'package:payment_app/components/my_sliver_app_bar.dart';
import 'package:payment_app/database/dabase_handler.dart';
import 'package:payment_app/localization/locals.dart';
import 'package:payment_app/models/notes_models.dart';
import 'package:payment_app/pages/edit_note_page.dart';
import 'package:payment_app/pages/notes_page.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<NotesModel> notes = [];
  List<NotesModel> filteredNotes = [];
  TextEditingController searchController = TextEditingController();
  List<NotesModel> selectedNotes = [];
  List<String> categories = [];
  Map<String, String> categoryMap = {};
  final ScrollController _scrollController = ScrollController();
  int currentRow = 0;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _fetchCategories();
    _fetchNotes();
    _scrollController.addListener(_updateCurrentRow);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateCurrentRow);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateCurrentRow() {
    if (_scrollController.hasClients) {
      setState(() {
        currentRow = (_scrollController.offset / 56.0).round();
      });
    }
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
  }

  void _fetchCategories() {
    DatabaseHandler.getCategories().listen((fetchedCategories) {
      setState(() {
        categoryMap = fetchedCategories;
        _fetchNotes();
      });
    });
  }

  void _fetchNotes() async {
    final notesStream = DatabaseHandler.getNotes();
    notesStream.listen((fetchedNotes) {
      setState(() {
        notes = fetchedNotes
          ..sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) {
              return 0;
            } else if (a.createdAt == null) {
              return 1;
            } else if (b.createdAt == null) {
              return -1;
            } else {
              return b.createdAt!.compareTo(a.createdAt!);
            }
          });
        filteredNotes = notes;
      });
    });
  }

  void searchNotes(String query) {
    if (query.isNotEmpty) {
      setState(() {
        filteredNotes = notes.where((note) {
          final titleMatches =
              note.title.toLowerCase().contains(query.toLowerCase());
          final bodyMatches =
              note.body.toLowerCase().contains(query.toLowerCase());
          final categoryMatches =
              note.category?.toLowerCase().contains(query.toLowerCase()) ??
                  false;

          return titleMatches || bodyMatches || categoryMatches;
        }).toList();
      });
    } else {
      setState(() {
        filteredNotes = notes;
      });
    }
  }

  void _onTap(NotesModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNotePage(notesModel: note),
      ),
    );
  }

  void showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.filter_list, color: Colors.indigoAccent),
              SizedBox(width: 10),
              Text(
                'Filter Notes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildDialogOption(context, Icons.note, 'My Notes'),
              _buildDialogOption(context, Icons.business_center, 'Office'),
              _buildDialogOption(context, Icons.meeting_room, 'Meetings'),
              _buildDialogOption(context, Icons.location_city, 'Visits'),
              _buildDialogOption(context, Icons.work, 'Professional'),
              _buildDialogOption(context, Icons.family_restroom, 'Family'),
              _buildDialogOption(context, Icons.person, 'Personal'),
              _buildDialogOption(context, Icons.more_horiz, 'Others'),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  child: Container(
                    width: 80.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: Colors.indigoAccent,
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "All Notes",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      filteredNotes = notes;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogOption(
      BuildContext context, IconData icon, String option) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigoAccent),
      title: Text(
        option,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      onTap: () {
        setState(() {
          filteredNotes =
              notes.where((note) => note.category == option).toList();
        });
        Navigator.of(context).pop();
      },
    );
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _scrollToStart() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const MyDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          MySliverAppBar(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "My Notes",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 25,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AnimatedOpacity(
                            opacity: filteredNotes.isEmpty ? 0 : 1,
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              '${filteredNotes.length} notes',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: AnimSearchBar(
                            closeSearchOnSuffixTap: true,
                            suffixIcon: const Icon(
                              FontAwesomeIcons.xmark,
                              size: 30,
                            ),
                            prefixIcon: const Icon(
                              FontAwesomeIcons.magnifyingGlass,
                              size: 30,
                            ),
                            boxShadow: false,
                            width: 200.w,
                            textController: searchController,
                            onSuffixTap: () {
                              searchNotes(searchController.text);
                            },
                            onSubmitted: (value) {
                              searchNotes(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 35.w,
                          height: 35.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade700),
                          ),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                showFilterDialog(context);
                              },
                              child: FaIcon(
                                FontAwesomeIcons.filter,
                                color: Colors.grey[700],
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotesPage(),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 20.w),
                            width: 35.w,
                            height: 35.h,
                            decoration: BoxDecoration(
                              color: Colors.indigoAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                FluentIcons.add_48_regular,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            child: const Text(""),
          ),
        ],
        body: Padding(
          padding: const EdgeInsets.only(
              bottom: 20.0), // Add some padding at the bottom
          child: Stack(
            children: [
              // The main scrollable content
              Positioned.fill(
                child: ListView(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        filteredNotes.isEmpty
                            ? _noNotesWidget()
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _scrollController,
                                child: DataTable(
                                  columns: _buildColumns(),
                                  rows: _buildRows(filteredNotes),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
              // Left icon button
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 35.w,
                  height: 35.h,
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.transparent,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: AnimatedOpacity(
                      opacity: _scrollController.hasClients &&
                              _scrollController.offset == 0
                          ? 0.5
                          : 1.0,
                      duration: const Duration(milliseconds: 500),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 30,
                        color: _scrollController.hasClients &&
                                _scrollController.offset == 0
                            ? const Color.fromARGB(255, 167, 180, 253)
                            : Colors.indigoAccent,
                      ),
                    ),
                    onPressed: _scrollController.hasClients &&
                            _scrollController.offset == 0
                        ? null
                        : _scrollToStart,
                  ),
                ),
              ),
              // Right icon button
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 35.w,
                  height: 35.h,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.transparent,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: AnimatedOpacity(
                      opacity: _scrollController.hasClients &&
                              _scrollController.offset >=
                                  _scrollController.position.maxScrollExtent
                          ? 0.5
                          : 1.0,
                      duration: const Duration(milliseconds: 500),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 30,
                        color: _scrollController.hasClients &&
                                _scrollController.offset >=
                                    _scrollController.position.maxScrollExtent
                            ? const Color.fromARGB(255, 167, 180, 253)
                            : Colors.indigoAccent,
                      ),
                    ),
                    onPressed: _scrollController.hasClients &&
                            _scrollController.offset >=
                                _scrollController.position.maxScrollExtent
                        ? null
                        : _scrollToEnd,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noNotesWidget() {
    return Center(
      child: Text(
        'No notes available',
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: 18,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(
        label: Text(
          LocalData.image.getString(context),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          LocalData.date.getString(context),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          "Title",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          LocalData.category.getString(context),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          LocalData.note.getString(context),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
  }

  void _onNoteSelected(String noteId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('notes')
          .doc(noteId)
          .get();

      if (doc.exists) {
        NotesModel notesModel = NotesModel.fromSnapshot(doc);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditNotePage(notesModel: notesModel),
          ),
        );
      } else {
        // Handle the case where the note does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note not found')),
        );
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching note: $e')),
      );
    }
  }

  List<DataRow> _buildRows(List<NotesModel> notes) {
    return notes.map((note) {
      final isSelected = selectedNotes.contains(note);
      final formattedDate = note.createdAt != null
          ? DateFormat('dd-MMM-yy').format(note.createdAt!.toDate())
          : 'Unknown';
      final imageCount = note.imageUrls != null ? note.imageUrls!.length : 0;
      final bodyLength = note.body.length;

      return DataRow(
        selected: isSelected,
        onSelectChanged: (isSelected) {
          if (isSelected != null && isSelected) {
            _onNoteSelected(note.id!); // Navigates to note details page
          }
        },
        cells: [
          DataCell(
            Row(
              children: [
                note.imageUrls != null && note.imageUrls!.isNotEmpty
                    ? Container(
                        width: 70,
                        height: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              note.imageUrls!.first,
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                      )
                    : const Text('No Image'),
                SizedBox(width: 1.w),
                Text(' x$imageCount'),
              ],
            ),
          ),
          _buildDataCell(formattedDate, true),
          _buildDataCell(note.title, false),
          _buildDataCell(note.category ?? 'Uncategorized', false),
          DataCell(
            Row(
              children: [
                Expanded(
                  child: Text(note.body),
                ),
                SizedBox(width: 8.w),
                Text('(${bodyLength.toString()})'),
              ],
            ),
          ),
        ],
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                "Are you sure you want to delete this note?",
                style: GoogleFonts.poppins(),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    myButton(
                      "No",
                      Colors.white,
                      () {
                        Navigator.pop(context);
                      },
                      Colors.black,
                      true,
                    ),
                    myButton(
                      "Yes",
                      Colors.red, // Changed to red for a stronger warning
                      () async {
                        await DatabaseHandler.deleteNote(note.id!);
                        setState(() {
                          notes.remove(note);
                          filteredNotes.remove(note);
                          selectedNotes.remove(note);
                        });
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      },
                      Colors.white,
                      true,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }).toList();
  }

  DataCell _buildDataCell(String text, bool? isDate) {
    return DataCell(
      Container(
        alignment: Alignment.centerLeft,
        width: isDate == false ? 80 : 90,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}
