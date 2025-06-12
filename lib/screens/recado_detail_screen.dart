import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chama_app/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class RecadoDetailScreen extends StatefulWidget {
  final String title;
  final String content;
  final DateTime date;
  final String imageUrl;

  const RecadoDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    required this.imageUrl,
  });

  @override
  State<RecadoDetailScreen> createState() => _RecadoDetailScreenState();
}

class _RecadoDetailScreenState extends State<RecadoDetailScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("pt-BR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() { _isPlaying = false; });
    });
  }

  Future<void> _toggleSpeak() async {
    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() { _isPlaying = false; });
    } else {
      if (widget.content.isNotEmpty) {
        String fullText = "${widget.title}. ${widget.content}";
        await _flutterTts.speak(fullText);
        setState(() { _isPlaying = true; });
      }
    }
  }

  void _shareRecado() {
    final textToShare = 'Recado do Chama Coral: ${widget.title}\n\n${widget.content}';
    Share.share(textToShare, subject: widget.title);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos um Scaffold normal para este layout mais estruturado.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recado"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Partilhar Recado',
            onPressed: _shareRecado,
          )
        ],
      ),
      body: Column(
        children: [
          // 1. Imagem de Cabeçalho
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[800]),
              errorWidget: (context, url, error) => Container(color: Colors.black),
            ),
          ),
          
          // 2. Área de Conteúdo com scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nexa',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Data
                  Text(
                    DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(widget.date),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Divider(height: 40, thickness: 1),
                  // Conteúdo do Recado
                  Text(
                    widget.content,
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.6,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Barra de Controlo de Áudio no Fundo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleSpeak,
                  icon: Icon(_isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 28),
                  label: Text(_isPlaying ? 'Parar Leitura' : 'Ouvir Recado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
