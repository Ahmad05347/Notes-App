import 'package:cloud_firestore/cloud_firestore.dart';

class NotesModel {
  final String? id;
  final String title;
  final String body;
  final String? category;
  final List<String>? imageUrls;
  final List<String>? videoUrls;
  final List<String>? recordingUrls;
  final List<String>? imageTags;
  final List<String>? videoTags;
  final List<String>? recordingTags;
  final List<String>? transcriptions;
  final String? location;
  final Timestamp? createdAt;

  NotesModel({
    this.id,
    required this.title,
    required this.body,
    this.category,
    this.imageUrls,
    this.videoUrls,
    this.recordingUrls,
    this.imageTags,
    this.videoTags,
    this.recordingTags,
    this.transcriptions,
    this.location,
    this.createdAt,
  });

  factory NotesModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotesModel(
      id: doc.id,
      title: data['title'] as String,
      body: data['body'] as String,
      category: data['category'] as String?,
      imageUrls:
          data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : [],
      videoUrls:
          data['videoUrls'] != null ? List<String>.from(data['videoUrls']) : [],
      recordingUrls: data['recordingUrls'] != null
          ? List<String>.from(data['recordingUrls'])
          : [],
      imageTags:
          data['imageTags'] != null ? List<String>.from(data['imageTags']) : [],
      videoTags:
          data['videoTags'] != null ? List<String>.from(data['videoTags']) : [],
      recordingTags: data['recordingTags'] != null
          ? List<String>.from(data['recordingTags'])
          : [],
      transcriptions: data['transcriptions'] != null
          ? List<String>.from(data['transcriptions'])
          : [],
      location: data['location'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'title': title,
      'body': body,
      'category': category,
      'imageUrls': imageUrls ?? [],
      'videoUrls': videoUrls ?? [],
      'recordingUrls': recordingUrls ?? [],
      'imageTags': imageTags ?? [],
      'videoTags': videoTags ?? [],
      'recordingTags': recordingTags ?? [],
      'transcriptions': transcriptions ?? [],
      'location': location,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
