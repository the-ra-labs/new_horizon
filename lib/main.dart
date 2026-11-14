import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'splash_screen.dart';
import 'theme/app_colors.dart';
import 'utils/keyboard_scroll.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'New Horizon Properties',
      theme: ThemeData.dark(useMaterial3: true)
          .copyWith(scaffoldBackgroundColor: AppColors.bg),
      // Poori app (har screen, dialog aur sheet) par keyboard scroll
      builder: (context, child) =>
          KeyboardScroller(child: child ?? const SizedBox.shrink()),
      home: const SplashScreen(next: AuthScreen()),
    );
  }
}
