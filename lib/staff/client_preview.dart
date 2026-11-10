import 'package:flutter/material.dart';
import '../data/staff_data.dart';
import '../screens/home_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/press_scale.dart';

/// Staff ko client app dikhata hai (upar "Back to Staff" banner ke saath)
void openClientView(BuildContext context) {
  Session.previewing = true;
  Navigator.of(context)
      .push(PageRouteBuilder<void>(
    settings: const RouteSettings(name: 'client-home'),
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, __, ___) => const ClientPreview(),
    transitionsBuilder: (_, a, __, child) =>
        FadeTransition(opacity: a, child: child),
  ))
      .then((_) {
    Session.previewing = false;
  });
}

class ClientPreview extends StatelessWidget {
  const ClientPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg,
      child: Column(children: [
        Container(
          width: double.infinity,
          color: const Color(0xFF2A1F0E),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                const Icon(Icons.visibility_outlined,
                    size: 16, color: AppColors.peach),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Viewing as client • ${Session.staff?.name ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.peach,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                PressScale(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.arrow_back_rounded,
                          size: 14, color: Colors.black),
                      SizedBox(width: 4),
                      Text('Back to Staff',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: const HomeScreen(),
          ),
        ),
      ]),
    );
  }
}