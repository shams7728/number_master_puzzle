import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _starsAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _starsOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Stars animation controller
    _starsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
    ));

    // Stars opacity animation
    _starsOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starsAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSplashSequence() async {
    // Start stars animation first
    _starsAnimationController.forward();

    // Delay logo animation slightly
    await Future.delayed(const Duration(milliseconds: 300));
    _logoAnimationController.forward();

    // Initialize game systems in background
    _initializeGameSystems();

    // Navigate after 3 seconds or initialization completion
    await Future.delayed(const Duration(seconds: 3));
    _navigateToHome();
  }

  void _initializeGameSystems() async {
    try {
      // Simulate loading saved game state
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate initializing Flutter game engine
      await Future.delayed(const Duration(milliseconds: 300));

      // Simulate preparing grid layouts
      await Future.delayed(const Duration(milliseconds: 200));

      // Simulate checking for existing progress data
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      // Handle initialization errors gracefully
      debugPrint('Initialization error: $e');
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home-screen');
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _starsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A148C), // Deep purple base
              Color(0xFF6A1B9A), // Lighter purple accent
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated stars background
              _buildStarsBackground(),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo
                    _buildAnimatedLogo(),

                    SizedBox(height: 8.h),

                    // Loading indicator
                    _buildLoadingIndicator(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarsBackground() {
    return AnimatedBuilder(
      animation: _starsOpacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _starsOpacityAnimation.value,
          child: Stack(
            children: [
              // Generate scattered stars
              ...List.generate(20, (index) {
                final random = (index * 37) % 100; // Pseudo-random positioning
                return Positioned(
                  left: (random * 3.5).w,
                  top: (random * 0.8).h,
                  child: Container(
                    width: 2.w,
                    height: 2.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),

              // Additional larger stars
              ...List.generate(8, (index) {
                final random = (index * 73) % 100; // Different pseudo-random
                return Positioned(
                  left: (random * 3.2).w,
                  top: (random * 0.9).h,
                  child: CustomIconWidget(
                    iconName: 'star',
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 3.w,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoScaleAnimation, _logoFadeAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _logoFadeAnimation.value,
          child: Transform.scale(
            scale: _logoScaleAnimation.value,
            child: Column(
              children: [
                // Game logo icon
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'calculate',
                      color: Colors.white,
                      size: 12.w,
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                // Game title
                Text(
                  'Number Master',
                  style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                SizedBox(height: 1.h),

                // Subtitle
                Text(
                  'Master the Numbers',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        // Loading text
        Text(
          'Loading...',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            letterSpacing: 0.5,
          ),
        ),

        SizedBox(height: 2.h),

        // Platform-native loading indicator
        SizedBox(
          width: 6.w,
          height: 6.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}
