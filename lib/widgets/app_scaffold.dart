// lib/widgets/app_scaffold.dart

import 'package:flutter/material.dart';
import 'package:chama_app/widgets/my_drawer.dart'; // Importa nosso Drawer

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const AppScaffold({
    required this.title,
    required this.body,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(), // O Drawer é sempre o mesmo
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontFamily: 'Nexa', color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF192F3C),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: body, // O corpo da tela é o que vai mudar
    );
  }
}