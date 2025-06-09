import 'package:chama_app/providers/theme_provider.dart';
import 'package:chama_app/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Acessa o nosso ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AppScaffold(
      title: 'Configurações',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Tema Escuro', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Ative para uma melhor visualização em ambientes com pouca luz.', style: TextStyle(color: Colors.white70)),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                // Chama a função para trocar o tema
                final provider = Provider.of<ThemeProvider>(context, listen: false);
                provider.toggleTheme(value);
              },
              secondary: Icon(
                themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                color: Colors.white,
              ),
              activeColor: Colors.red,
            ),
            const Divider(color: Colors.white24),
            // Aqui você pode adicionar a lógica para "Limpar Cache" no futuro
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.white70),
              title: const Text('Limpar Cache de Músicas', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Libera espaço removendo áudios e PDFs baixados.', style: TextStyle(color: Colors.white70)),
              onTap: () {
                // Lógica para limpar o cache (a ser implementada)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidade a ser implementada!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
