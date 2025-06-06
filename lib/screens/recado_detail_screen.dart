import 'package:chama_app/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class RecadoDetailScreen extends StatelessWidget {
  final String title;
  final String content;

  const RecadoDetailScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Recado",
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/wallpaper.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            content,
            style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
          ),
        ),
      ),
    );
  }
}