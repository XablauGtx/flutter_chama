import 'package:flutter/material.dart';
import 'package:chama_app/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chama_app/firebase_options.dart';


// Classe personalizada para ocultar o indicador de rolagem
class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child; // Retorna o filho diretamente, sem barra de rolagem
  }
}

// A função main precisa ser assíncrona para usar await
void main() async {
  // Garante que os bindings do Flutter estejam inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chama Coral',
      theme: ThemeData(
        // Removi o fontFamily direto aqui. É melhor aplicar no TextTheme
        // ou diretamente nos Text widgets onde 'Nexa' é necessário.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF192F3C)),
        // Se você quiser que o Nexa seja o padrão, pode tentar assim:
        // textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Nexa'),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      scrollBehavior: NoThumbScrollBehavior(),
    );
  }
}