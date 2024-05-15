import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:savorease_app/screens/login_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Lottie.asset(
          'assets/animation/splash_logo.json',
          width: MediaQuery.of(context).size.width *
              10, // Adjust the width as needed
          height: MediaQuery.of(context).size.height *
              10, // Adjust the height as needed
        ),
      ),
      nextScreen: const LoginPage(),
      duration: 3500,
      backgroundColor: Colors.white,
    );
  }
}
