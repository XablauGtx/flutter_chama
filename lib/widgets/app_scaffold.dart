// lib/widgets/app_scaffold.dart

import 'package:flutter/material.dart';
import 'package:chama_app/widgets/my_drawer.dart'; // Importa nosso Drawer

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;

  const AppScaffold({
    required this.title,
    required this.body,
    this.bottom,
    this.actions,
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
        bottom: bottom,
        actions: actions,
      ),
      // --- MUDANÇA APLICADA AQUI ---
      // O body do Scaffold agora é um Container com a imagem de fundo.
      // O conteúdo específico da sua tela (o 'body' que passamos) é colocado como filho dele.
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/wallpaper.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: body,
      ),
    );
  }
}
