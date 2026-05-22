import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const DikriApp());
}

class DikriApp extends StatelessWidget {
  const DikriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ذِكري',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      locale: const Locale('ar'),
      // Wrap the whole app in RTL
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const WelcomeScreen(),
    );
  }
}
