import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/session_service.dart';
import 'home_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool isNavigating = false;

  // ============================================================
  // PDF GUIDE URL
  // ============================================================
  //
  // Android Emulator:
  // 10.0.2.2
  //
  // Flutter Web/Desktop:
  // localhost
  //
  // Jika sudah menggunakan hosting,
  // ganti URL ini dengan URL hosting.
  //
  static const String guidePdfUrl =
      "https://sightsavers.id/foruga_admin/uploads/panduan/FORUGA_READ_Panduan_Aplikasi.pdf";

  // ============================================================
  // OPEN PDF GUIDE
  // ============================================================

  Future<void> _openGuidePdf(BuildContext context) async {
    final uri = Uri.parse(guidePdfUrl);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The PDF guide could not be opened.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to open the PDF guide: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // CONTINUE
  // ============================================================

  Future<void> continueToApp() async {
    if (!mounted || isNavigating) return;

    setState(() {
      isNavigating = true;
    });

    // Check session ONLY after the user presses Continue.
    final loggedIn = await SessionService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      goToHome();
    } else {
      goToLogin();
    }
  }

  // ============================================================
  // GO TO HOME
  // ============================================================

  void goToHome() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
    );
  }

  // ============================================================
  // GO TO LOGIN
  // ============================================================

  void goToLogin() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6DD5FA),
              Color(0xFF2980B9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ==================================================
                    // ICON
                    // ==================================================

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6DD5FA)
                            .withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 70,
                        color: Color(0xFF2980B9),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // TITLE
                    // ==================================================

                    const Text(
                      "FORUGA READ",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    // ==================================================
                    // SUBTITLE
                    // ==================================================

                    const Text(
                      "Interactive Story Learning App",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // SHORT DESCRIPTION
                    // ==================================================

                    const Text(
                      "Learn English through Indonesian folktales, "
                      "interactive stories, and fun educational games.",
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.55,
                        color: Color(0xFF455A64),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // FEATURE SUMMARY
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6FC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '📖 Read Stories\n'
                        '🎮 Play Learning Games\n'
                        '🏆 Earn Scores & Improve\n'
                        '📚 Learn English',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F5F8B),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // PDF GUIDE
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: isNavigating
                            ? null
                            : () {
                                _openGuidePdf(context);
                              },
                        icon: const Icon(
                          Icons.picture_as_pdf_rounded,
                        ),
                        label: const Text(
                          "Read the App Guide",
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2980B9),
                          side: const BorderSide(
                            color: Color(0xFF2980B9),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // CONTINUE BUTTON
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF2980B9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                          elevation: 6,
                        ),
                        onPressed: isNavigating
                            ? null
                            : () {
                                continueToApp();
                              },
                        child: isNavigating
                            ? const SizedBox(
                                width: 25,
                                height: 25,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // INFORMATION
                    // ==================================================

                    const Text(
                      "Tap Continue to enter the application.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}