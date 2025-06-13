import 'package:chama_app/firebase_options.dart';
import 'package:chama_app/models/audio_handler.dart';
import 'package:chama_app/providers/theme_provider.dart';
import 'package:chama_app/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:chama_app/services/notification_service.dart'; // Importa o seu novo serviço

late MyAudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  audioHandler = await initAudioService();

  await initializeDateFormatting('pt_BR', null);

  // Envolvemos o nosso app com o ChangeNotifierProvider.
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
    // Usamos um Consumer para que o MaterialApp se reconstrua quando o tema mudar.
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Chama Coral',
          
          // Define os temas e qual deles está ativo
          themeMode: themeProvider.themeMode,
          
          // TEMA CLARO
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF192F3C),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.grey[200],
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF192F3C),
              foregroundColor: Colors.white,
            ),
            cardColor: Colors.white,
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.black87),
              titleMedium: TextStyle(color: Colors.black),
            ),
              iconTheme: const IconThemeData(color: Colors.black54),
          ),

          // TEMA ESCURO
          darkTheme: ThemeData(
             useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF192F3C),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF192F3C),
              foregroundColor: Colors.white,
            ),
            cardColor: const Color(0xFF2D2D2D),
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
