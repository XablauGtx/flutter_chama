// lib/screens/recados_screen.dart
import 'package:flutter/material.dart';

class RecadosScreen extends StatelessWidget {
  const RecadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recados',
          style: TextStyle(
            fontFamily: 'Nexa',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF192F3C), // Uma cor para o AppBar desta tela
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Retorna à tela anterior
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/wallpaper.png'), // Use o mesmo wallpaper
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Text(
            'Esta é a tela de Recados!',
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