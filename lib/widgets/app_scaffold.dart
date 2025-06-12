import 'package:flutter/material.dart';
import 'package:chama_app/widgets/my_drawer.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;
  final bool extendBodyBehindAppBar; // NOVO: Para o layout imersivo
  final Color? scaffoldBackgroundColor; // NOVO: Para controlar a cor de fundo

  const AppScaffold({
    required this.title,
    required this.body,
    this.bottom,
    this.actions,
    this.extendBodyBehindAppBar = false, // Valor padrão é 'false'
    this.scaffoldBackgroundColor, // Por defeito, usará a cor do tema
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final wallpaperPath = isDarkMode 
        ? 'assets/images/wallpaper.png' 
        : 'assets/images/wallpaper_light.png';

    // A lógica do Scaffold agora é mais flexível
    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar, // <<<--- USA A NOVA PROPRIEDADE
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: Text(title, style: TextStyle(fontFamily: 'Nexa', color: Theme.of(context).appBarTheme.foregroundColor)),
        centerTitle: true,
        // Torna a AppBar transparente se o layout for imersivo
        backgroundColor: extendBodyBehindAppBar ? Colors.transparent : Theme.of(context).appBarTheme.backgroundColor,
        elevation: extendBodyBehindAppBar ? 0 : null, // Remove a sombra no modo imersivo
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
      // Usa a cor de fundo passada ou a cor padrão do tema
      backgroundColor: scaffoldBackgroundColor, 
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // O papel de parede só é aplicado se não estivermos a usar um layout imersivo
        decoration: !extendBodyBehindAppBar 
            ? BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(wallpaperPath),
                  fit: BoxFit.cover,
                ),
              ) 
            : null,
        child: body,
      ),
    );
  }
}
