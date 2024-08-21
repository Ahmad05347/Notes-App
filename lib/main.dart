import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:payment_app/database/dabase_handler.dart';
import 'package:payment_app/localization/locals.dart';
import 'package:payment_app/models/notes_models.dart';
import 'package:payment_app/pages/edit_note_page.dart';
import 'package:payment_app/pages/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  await ScreenUtil.ensureScreenSize();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.env["STRIPE_PUBLISH_KEY"]!;
  await Stripe.instance.applySettings();
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity, // For Android
  );

  runApp(
    const MyApp(),
  );
}

Future<void> _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {
  String? payload = notificationResponse.payload;
  if (payload != null) {
    // Fetch the note details from the database using the payload (noteId)
    NotesModel? note = await DatabaseHandler.getNoteById(payload);
    if (note != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => EditNotePage(notesModel: note),
        ),
      );
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    configureLocalization();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
          localizationsDelegates: localization.localizationsDelegates,
          supportedLocales: localization.supportedLocales,
          locale: localization.currentLocale,
        );
      },
    );
  }

  void configureLocalization() {
    localization.init(
      mapLocales: LOCALE,
      initLanguageCode: "en",
    );
    localization.onTranslatedLanguage = onTranslatedLnaguage;
  }

  void onTranslatedLnaguage(Locale? locale) {
    setState(() {});
  }
}
