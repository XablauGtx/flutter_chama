import 'package:flutter/material.dart';

class Quatro_vozesScreen extends StatelessWidget {
  const Quatro_vozesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Oração',
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
            'Esta é a tela de Quatro_vozesScreen!',
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