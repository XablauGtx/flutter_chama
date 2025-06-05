// lib/widgets/app_scaffold.dart

import 'package:flutter/material.dart';
import 'package:chama_app/widgets/my_drawer.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final PreferredSizeWidget? bottom; // <<<--- PARÂMETRO NOVO E OPCIONAL

  const AppScaffold({
    required this.title,
    required this.body,
    this.bottom, // <<<--- ADICIONADO AO CONSTRUTOR
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
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
        bottom: bottom, // <<<--- USADO AQUI
      ),
      body: body,
    );
  }
}