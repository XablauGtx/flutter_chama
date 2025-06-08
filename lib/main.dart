import 'package:chama_app/firebase_options.dart';
import 'package:chama_app/home_screen.dart'; // Mantive o nome da sua tela principal
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // <<<--- CORREÇÃO 1
import 'models/audio_handler.dart';

late MyAudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  audioHandler = await initAudioService();

  await initializeDateFormatting('pt_BR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override // <<<--- CORREÇÃO 2
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chama App',
      theme: ThemeData(
        // Mantive o seu tema original
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF192F3C)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
