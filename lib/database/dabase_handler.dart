import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payment_app/models/notes_models.dart';

class DatabaseHandler {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String getUserId() {
    return _auth.currentUser?.uid ?? '';
  }

  static CollectionReference getUserNotesCollection() {
    return _firestore.collection('users').doc(getUserId()).collection('notes');
  }

  static CollectionReference getUserCategoriesCollection() {
    return _firestore
        .collection('users')
        .doc(getUserId())
        .collection('categories');
  }

  static Future<void> createNotes(NotesModel note) async {
    final id = getUserNotesCollection().doc().id;
    final newNote = NotesModel(
      id: id,
      title: note.title,
      body: note.body,
      category: note.category,
      imageUrls: note.imageUrls,
      videoUrls: note.videoUrls,
    ).toDocument();

    try {
      await getUserNotesCollection().doc(id).set(newNote);
      print('Note created successfully');
    } catch (e) {
      print("Error creating note: $e");
    }
  }

  static Future<void> updateNote(NotesModel note) async {
    try {
      await getUserNotesCollection().doc(note.id).update(note.toDocument());
      print('Note updated successfully');
    } catch (e) {
      print("Error updating note: $e");
    }
  }

  static Stream<List<NotesModel>> getNotes() {
    return getUserNotesCollection().snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return NotesModel.fromSnapshot(doc);
      }).toList();
    });
  }

  static Future<void> deleteNote(String id) async {
    try {
      await getUserNotesCollection().doc(id).delete();
      print('Note deleted successfully');
    } catch (e) {
      print("Error deleting note: $e");
    }
  }

  static Future<void> uploadCategories(List<String> categories) async {
    try {
      final batch = _firestore.batch();
      for (String category in categories) {
        final categoryDocRef =
            getUserCategoriesCollection().doc(category.toLowerCase());
        batch.set(categoryDocRef, {'name': category});
      }
      await batch.commit();
      print('Categories uploaded successfully.');
    } catch (e) {
      print('Error uploading categories: $e');
    }
  }

  static Stream<Map<String, String>> getCategories() {
    return getUserCategoriesCollection().snapshots().map((querySnapshot) {
      return Map.fromEntries(
        querySnapshot.docs.map(
          (doc) => MapEntry(doc.id, doc['name'] as String),
        ),
      );
    });
  }

  static Future<NotesModel?> getNoteById(String noteId) async {
    try {
      final doc = await getUserNotesCollection().doc(noteId).get();
      if (doc.exists) {
        return NotesModel.fromSnapshot(doc);
      }
    } catch (e) {
      print("Error fetching note: $e");
    }
    return null;
  }
}
