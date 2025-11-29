import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/enrolled_courses_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // For web, provide generated options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    // For Android/iOS/etc use native configuration (google-services.json / GoogleService-Info.plist)
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Assignment',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/courses': (_) => const CoursesScreen(),
        '/enrolled': (_) => const EnrolledCoursesScreen(),
      },
    );
  }
}
