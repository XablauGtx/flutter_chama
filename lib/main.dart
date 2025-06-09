import 'package:chama_app/firebase_options.dart';
import 'package:chama_app/models/audio_handler.dart';
import 'package:chama_app/providers/theme_provider.dart';
import 'package:chama_app/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

late MyAudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  audioHandler = await initAudioService();

  await initializeDateFormatting('pt_BR', null);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Chama App',
          themeMode: themeProvider.themeMode,
          
          // --- TEMA CLARO DEFINIDO ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF673AB7), // Roxo como cor principal
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.grey[200], // Fundo levemente cinza
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF673AB7),
              foregroundColor: Colors.white, // Texto e ícones brancos na AppBar
            ),
            cardColor: Colors.white,
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.black87), // Cor do texto principal
              titleMedium: TextStyle(color: Colors.black), // Cor do título
            ),
             iconTheme: const IconThemeData(color: Colors.black54), // Cor padrão dos ícones
          ),

          // --- TEMA ESCURO DEFINIDO ---
          darkTheme: ThemeData(
             useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF192F3C),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: Colors.black, // Fundo preto
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF192F3C),
              foregroundColor: Colors.white,
            ),
            cardColor: const Color(0xFF1E1E1E), // Cor dos cards no modo escuro
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white70),
              titleMedium: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white70),
          ),

          home: const HomeScreen(),
        );
      },
    );
  }
}
