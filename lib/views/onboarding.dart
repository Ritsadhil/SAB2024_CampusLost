import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_theme.dart';
import '../theme/widgets.dart';
import 'login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Lapor Barang Hilang',
      description:
          'Bantu temukan barangmu yang hilang dengan cepat di area kampus.',
      icon: Icons.search_rounded,
      color: Color(0xFFEEF1FB),
      iconColor: Color(0xFF1D3EAC),
    ),
    _OnboardingData(
      title: 'Temukan & Kembalikan',
      description:
          'Laporkan barang temuan agar dapat dikembalikan kepada pemilik aslinya.',
      icon: Icons.volunteer_activism_rounded,
      color: Color(0xFFEEF9F1),
      iconColor: Color(0xFF1A7A3C),
    ),
    _OnboardingData(
      title: 'Verifikasi Aman',
      description:
          'Sistem verifikasi berlapis memastikan barang kembali ke pemilik yang tepat.',
      icon: Icons.verified_user_rounded,
      color: Color(0xFFFFF4EE),
      iconColor: Color(0xFFD4650A),
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: TextButton(
                  onPressed: _goToLogin,
                  child: const Text(
                    'Lewati',
                    style: TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingPage(data: page);
                },
              ),
            ),

            // Indicator + button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppTheme.primary,
                      dotColor: const Color(0xFFD9D9D9),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      spacing: 6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Mulai Sekarang'
                        : 'Lanjut',
                    onPressed: _next,
                    icon: const Icon(Icons.arrow_forward_rounded,
                        size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.iconColor,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Illustration card
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: data.color,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Icon(
                  data.icon,
                  size: 100,
                  color: data.iconColor.withOpacity(0.6),
                ),
              ),
            ),
          ),

          const SizedBox(height: 36),

          // Title
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textGrey,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
