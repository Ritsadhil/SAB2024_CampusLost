import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'views/onboarding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// 1. Tambahkan kata 'async' di sebelah main()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Sisipkan inisialisasi Firebase di sini
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Kodingan aslimu tetap dipertahankan di bawahnya
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const CampusLostApp());
}

class CampusLostApp extends StatelessWidget {
  const CampusLostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusLost',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const OnboardingScreen(),
    );
  }
}