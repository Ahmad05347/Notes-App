import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

const List<MapLocale> LOCALE = [
  MapLocale(
    "en",
    LocalData.EN,
  ),
  MapLocale(
    "ar",
    LocalData.AR,
  ),
];

mixin LocalData {
  static const String noteTitle = "noteTitle";
  static const String title = "title";
  static const String body = "body";
  static const String category = "category";
  static const String note = "note";
  static const String image = "image";
  static const String date = "date";
  static const String deleteConfirmation = "deleteConfirmation";
  static const String yes = "yes";
  static const String no = "no";
  static const String homepage = "homepage";
  static const String payments = "payments";
  static const String language = "language";
  static const String settings = "settings";
  static const String logout = "logout";
  static const String gallery = "gallery";
  static const String camera = "camera";
  static const String galleryVideo = "Gallery video";
  static const String cameraVideo = "Camera Video";

  static const Map<String, dynamic> EN = {
    noteTitle: "Title",
    title: "Add Note",
    body: "Start Typing...",
    category: "Category",
    note: "Point(s)",
    image: "Image",
    date: "Date",
    deleteConfirmation: "Are you sure you want to delete this note?",
    yes: "Yes",
    no: "No",
    homepage: "HOMEPAGE",
    payments: "PAYMENTS",
    language: "LANGUAGE",
    settings: "SETTINGS",
    logout: "LOGOUT",
    gallery: "Add From Gallery",
    camera: "Add From Camera",
    galleryVideo: "Gallery Video",
    cameraVideo: "Camera Video",
  };
  static const Map<String, dynamic> AR = {
    noteTitle: "عنوان الملاحظة",
    title: "عنوان",
    body: "ابدأ الطباعة",
    category: "فئة",
    note: "ملاحظة",
    image: "صورة",
    date: "تاريخ",
    deleteConfirmation: "هل أنت متأكد أنك تريد حذف هذه الملاحظة؟",
    yes: "نعم",
    no: "لا",
    homepage: "الصفحة الرئيسية",
    payments: "المدفوعات",
    language: "اللغة",
    settings: "الإعدادات",
    logout: "تسجيل الخروج",
    gallery: "صالة عرض",
    camera: "آلة تصوير",
    galleryVideo: "معرض فيديو",
    cameraVideo: "فيديو الكاميرا",
  };
  static String getString(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ar') {
      return AR[key] ?? key;
    }
    return EN[key] ?? key;
  }
}
