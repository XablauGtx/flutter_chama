import 'package:chama_app/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

class RecadoDetailScreen extends StatefulWidget {
  final String title;
  final String content;
  final DateTime date;

  const RecadoDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.date,
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

    _flutterTts.setStartHandler(() {
      if (mounted) setState(() { _isPlaying = true; });
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() { _isPlaying = false; });
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() { _isPlaying = false; });
      print("TTS Error: $msg");
    });
  }

  Future<void> _speak() async {
    if (widget.content.isNotEmpty) {
      String fullText = "${widget.title}. ${widget.content}";
      await _flutterTts.speak(fullText);
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Recado", // Título do AppBar
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Cabeçalho
            Text(
              "Recado para o coral",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
                fontFamily: 'Nexa',
              ),
            ),
            const SizedBox(height: 8),
            // Título do recado (pode ser omitido se já estiver no card)
            // Text(
            //   widget.title,
            //   style: const TextStyle(
            //     color: Colors.white,
            //     fontSize: 28,
            //     fontWeight: FontWeight.bold,
            //     fontFamily: 'Nexa',
            //   ),
            // ),

            const Spacer(flex: 1),

            // Card Amarelo para o conteúdo
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD15B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -50,
                    left: -15,
                    child: Icon(Icons.format_quote, size: 60, color: Colors.black.withOpacity(0.08)),
                  ),
                  Positioned(
                    bottom: -50,
                    right: -15,
                    child: Icon(Icons.format_quote, size: 60, color: Colors.black.withOpacity(0.08)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title, // Título dentro do card
                        style: const TextStyle(
                          color: Color(0xFF3D3D3D),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nexa'
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.content,
                        style: const TextStyle(
                          color: Color(0xFF3D3D3D),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR').format(widget.date),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // Botão central de Play/Pause
            ElevatedButton(
              onPressed: _isPlaying ? _stop : _speak,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor: const Color(0xFF192F3C),
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

