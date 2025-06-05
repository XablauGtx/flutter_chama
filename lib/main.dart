import 'package:flutter/material.dart';
import 'package:chama_app/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chama_app/firebase_options.dart';
// Não é mais necessário importar audio_service aqui, pois audio_handler.dart já o faz.
import 'package:chama_app/audio_handler.dart';

// Classe personalizada para ocultar o indicador de rolagem
class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child; // Retorna o filho diretamente, sem barra de rolagem
  }
}

// MUDE O TIPO DA VARIÁVEL AQUI
late MyAudioHandler audioHandler;

// A função main precisa ser assíncrona para usar await
void main() async {
  // Garante que os bindings do Flutter estejam inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa o serviço de áudio e obtém a instância do handler
  // A atribuição agora é compatível porque initAudioService retorna MyAudioHandler
  audioHandler = await initAudioService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chama Coral',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF192F3C)),
        // textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Nexa'),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      scrollBehavior: NoThumbScrollBehavior(),
    );
  }
}

// Para acessar o audioHandler em outras partes do seu app (por exemplo, na ContraltoScreen):
// 1. Importe o main.dart:
//    import 'package:chama_app/main.dart'; // Ou o caminho correto para seu main.dart
//
// 2. Use a variável audioHandler:
//    audioHandler.play();
//    audioHandler.pause();
//    audioHandler.skipToNext();
//    audioHandler.updatePlaylist(mediaItems); // Lembre-se desta!