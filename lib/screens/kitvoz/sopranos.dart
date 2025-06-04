import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

// Classe para representar uma música de forma mais organizada no código
class Music {
  final String id;
  final String titulo;
  final String url; // URL do áudio
  final String? letra; // Adicionado para a letra da música

  Music({
    required this.id,
    required this.titulo,
    required this.url,
    this.letra, // Removido o 'artista' aqui
  });

  factory Music.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Music(
      id: doc.id,
      titulo: data['titulo'] ?? 'Música desconhecida',
      url: data['url'] ?? '',
      // artista: data['artista'], // Removido esta linha
      letra: data['letra'], // Pega o campo 'letra'
    );
  }
}

class SopranoScreen extends StatefulWidget {
  const SopranoScreen({super.key});

  @override
  State<SopranoScreen> createState() => _SopranoScreenState();
}

class _SopranoScreenState extends State<SopranoScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Music> _musicList = []; // Lista de todas as músicas carregadas
  Music? _currentPlayingMusic; // Objeto da música atualmente tocando
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    print('SopranoScreen: initState chamado.'); // Adicionado para depuração
    _loadMusicList(); // Carrega a lista de músicas ao iniciar
    _setupAudioPlayerListeners(); // Configura os listeners do player
  }

  // Carrega as músicas do Firestore
 void _loadMusicList() {
  print('SopranoScreen: Tentando carregar lista de músicas...');
  FirebaseFirestore.instance
      .collection('naipes')
      .doc('sopranos')
      .collection('musicas')
      .snapshots()
      .listen((snapshot) {
    if (mounted) {
      print('SopranoScreen: Listener do Firestore ativado.');
      setState(() {
        _musicList = snapshot.docs.map((doc) => Music.fromFirestore(doc)).toList();
        print('SopranoScreen: Músicas carregadas: ${_musicList.length} itens.');
        if (_musicList.isEmpty) {
          print('SopranoScreen: A lista de músicas está vazia APÓS carregar do Firestore.');
        }
      });
    }
  }, onError: (error) {
    print('SopranoScreen: ERRO ao carregar músicas: $error');
  });
}
  // Configura os listeners do AudioPlayer
  void _setupAudioPlayerListeners() {
  _audioPlayer.onPlayerStateChanged.listen((state) {
    print('SopranoScreen: Player State Changed: $state');
    if (mounted) setState(() {});
  });

  _audioPlayer.onDurationChanged.listen((newDuration) {
    print('SopranoScreen: onDurationChanged: Nova duração: $newDuration'); // <-- Adicionado
    if (mounted) setState(() => _duration = newDuration);
  });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _position = Duration.zero;
          _audioPlayer.stop(); // Parar ao finalizar
          _playNextSong(); // Tentar tocar a próxima música automaticamente
        });
      }
    });
  }

  // Toca uma música específica
  Future<void> _playSong(Music music) async {
    if (_currentPlayingMusic?.id == music.id) {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(music.url));
      setState(() {
        _currentPlayingMusic = music;
        _position = Duration.zero; // Resetar posição para a nova música
        _duration = Duration.zero; // Resetar duração até ser lida
      });
    }
  }

  // Toca a próxima música na lista
  Future<void> _playNextSong() async {
    if (_musicList.isEmpty) return;
    int currentIndex = _musicList.indexWhere((m) => m.id == _currentPlayingMusic?.id);
    if (currentIndex != -1 && currentIndex < _musicList.length - 1) {
      await _playSong(_musicList[currentIndex + 1]);
    } else if (_currentPlayingMusic == null && _musicList.isNotEmpty) {
      await _playSong(_musicList.first);
    } else {
      setState(() {
        _currentPlayingMusic = null;
        _audioPlayer.stop();
        _position = Duration.zero;
        _duration = Duration.zero;
      });
    }
  }

  // Toca a música anterior na lista
  Future<void> _playPreviousSong() async {
    if (_musicList.isEmpty) return;
    int currentIndex = _musicList.indexWhere((m) => m.id == _currentPlayingMusic?.id);
    if (currentIndex > 0) {
      await _playSong(_musicList[currentIndex - 1]);
    } else if (_currentPlayingMusic == null && _musicList.isNotEmpty) {
      await _playSong(_musicList.first);
    } else {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.resume();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  @override
  Widget build(BuildContext context) {
    print('SopranoScreen: build chamado. _musicList.isEmpty: ${_musicList.isEmpty}'); // Adicionado para depuração
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kit Voz - Soprano',
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
        child: Column(
          children: [
            // PARTE DO PLAYER (FICA NO TOPO)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Capa da Música
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      // Usando o asset que você mencionou no código que me enviou.
                      // Se quiser uma imagem diferente, ajuste aqui.
                      'assets/images/chama_coral.png',
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width * 0.7,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),

                           Text(
                    _currentPlayingMusic?.titulo ?? 'Nenhuma música selecionada',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nexa',
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Barra de progresso
                  Slider(
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey[600],
                    min: 0,
                    max: _duration.inSeconds.toDouble(),
                    value: _position.inSeconds.clamp(0, _duration.inSeconds).toDouble(),
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await _audioPlayer.seek(position);
                    },
                  ),

                  // Tempo atual e duração
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Botões de controle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: Colors.white),
                        iconSize: 40,
                        onPressed: _playPreviousSong,
                      ),
                      IconButton(
                        icon: Icon(
                          _audioPlayer.state == PlayerState.playing
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.white,
                        ),
                        iconSize: 64,
                        onPressed: () {
                          if (_currentPlayingMusic != null) {
                            _playSong(_currentPlayingMusic!);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white),
                        iconSize: 40,
                        onPressed: _playNextSong,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white70),

            // Lista de músicas
            Expanded(
              child: _musicList.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma música encontrada.',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _musicList.length,
                      itemBuilder: (context, index) {
                        final music = _musicList[index];
                        return Card(
                          color: Colors.black54,
                          child: ListTile(
                            title: Text(
                              music.titulo,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Icon(
                              _currentPlayingMusic?.id == music.id &&
                                      _audioPlayer.state == PlayerState.playing
                                  ? Icons.equalizer
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onTap: () => _playSong(music),
                            onLongPress: () {
                              if (music.letra != null && music.letra!.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(music.titulo),
                                    content: SingleChildScrollView(
                                      child: Text(music.letra!),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text("Fechar"),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}