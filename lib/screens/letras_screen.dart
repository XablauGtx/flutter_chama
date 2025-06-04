// lib/screens/letras_screen.dart
import 'package:flutter/material.dart';

class LetrasScreen extends StatelessWidget {
  const LetrasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Letras',
          style: TextStyle(
            fontFamily: 'Nexa',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF192F3C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/wallpaper.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Text(
            'Esta é a tela de Letras!',
            style: TextStyle(
              fontFamily: 'Nexa',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}