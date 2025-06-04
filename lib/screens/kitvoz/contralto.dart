// lib/screens/kit_voz/contralto_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

class ContraltoScreen extends StatefulWidget {
  const ContraltoScreen({super.key});

  @override
  State<ContraltoScreen> createState() => _ContraltoScreenState();
}

class _ContraltoScreenState extends State<ContraltoScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingUrl;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPause(String url) async {
    if (_currentPlayingUrl == url) {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _currentPlayingUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kit Voz - Contralto', // Mude o título
          style: TextStyle(fontFamily: 'Nexa', color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF192F3C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/wallpaper.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          // *** ALTERAÇÃO AQUI: Caminho para 'naipes/contralto/musicas' ***
          stream: FirebaseFirestore.instance
              .collection('naipes')
              .doc('contralto') // O documento que representa o naipe
              .collection('musicas') // A subcoleção de músicas para este naipe
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar músicas: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Nenhuma música encontrada para Contralto.', style: TextStyle(color: Colors.white)));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String nomeMusica = data['titulo'] ?? 'Música desconhecida';
                String urlAudio = data['caporal'] ?? '';

                if (urlAudio.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Card(
                  color: const Color(0xFF192F3C).withOpacity(0.8),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      nomeMusica,
                      style: const TextStyle(fontFamily: 'Nexa', color: Colors.white, fontSize: 18),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        _currentPlayingUrl == urlAudio && _audioPlayer.state == PlayerState.playing
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        color: Colors.red,
                        size: 30,
                      ),
                      onPressed: () => _playPause(urlAudio),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}