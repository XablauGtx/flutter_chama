// lib/widgets/app_scaffold.dart

import 'package:flutter/material.dart';
import 'package:chama_app/widgets/my_drawer.dart';

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
    // --- LÓGICA PARA SELECIONAR O PAPEL DE PAREDE ---
    // 1. Verifica qual é o brilho do tema atual (claro ou escuro)
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 2. Define o caminho da imagem com base no tema
    //    (Certifique-se de que você tem um 'wallpaper_light.png' nos seus assets)
    final wallpaperPath = isDarkMode 
                          ? 'assets/images/wallpaper.png' 
                          : 'assets/images/wallpaper_light.png';

    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        // O AppBar agora usa as cores do tema definidas no main.dart
        title: Text(title, style: TextStyle(fontFamily: 'Nexa', color: Theme.of(context).appBarTheme.foregroundColor)),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Theme.of(context).appBarTheme.foregroundColor),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        bottom: bottom,
        actions: actions,
      ),
      // O body do Scaffold agora usa a imagem de fundo dinâmica
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(wallpaperPath), // <<<--- USA A IMAGEM CORRETA
            fit: BoxFit.cover,
          ),
        ),
        child: body,
      ),
    );
  }
}
