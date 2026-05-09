import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login.dart';

class ResetSentScreen extends StatefulWidget {
  final String email;

  const ResetSentScreen({super.key, required this.email});

  @override
  State<ResetSentScreen> createState() => _ResetSentScreenState();
}

class _ResetSentScreenState extends State<ResetSentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 0) {
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _resend() {
    if (_countdown > 0) return;
    setState(() => _countdown = 60);
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Instruksi telah dikirim ulang!')),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated icon
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_read_rounded,
                          size: 40,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Instruksi Terkirim!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGrey,
                          height: 1.6,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'Kami telah mengirimkan link pengaturan ulang password ke email ',
                          ),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(
                            text:
                                '. Silakan periksa kotak masuk atau folder spam Anda.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Countdown
                    Text(
                      _countdown > 0
                          ? 'Kirim ulang dalam $_countdown detik'
                          : 'Tidak menerima email?',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGrey,
                      ),
                    ),

                    if (_countdown == 0)
                      GestureDetector(
                        onTap: _resend,
                        child: const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Kirim ulang sekarang',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Back to login
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (_) => false,
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back_rounded,
                            size: 16,
                            color: AppTheme.primary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Kembali ke Login',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
