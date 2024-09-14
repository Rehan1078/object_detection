import 'dart:async';
import 'package:flutter/material.dart';

import 'MyHomeScreen.dart';


class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> with TickerProviderStateMixin {
  double _width = 400;
  double _height = 100;
  double _opacity = 0.0;  // Initially set the opacity to 0 (invisible)

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4), // Total duration for the fade effect
    );

    // Start the size and opacity animations
    setState(() {
      _width = _width + 1000;
      _height = _height + 1000;
      _opacity = 1.0; // Set opacity to 1 (fully visible) after the screen is loaded
    });

    // Start the animation after the screen builds
    _controller.forward();

    // Navigate to home screen after 4 seconds
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomeScreen()), // Corrected name
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedContainer(
          curve: Curves.bounceIn,
          width: _width,
          height: _height,
          duration: Duration(seconds: 4), // Animate the size over 4 seconds
          child: Center(
            child: AnimatedOpacity(
              opacity: _opacity, // Use the animated opacity value
              duration: Duration(seconds: 4), // Duration for the fade-in effect
              child: Text(
                "Welcome to the App",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 35,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
