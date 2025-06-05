import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

import 'package:chama_app/main.dart';
import 'package:chama_app/models/music.dart';
import 'package:chama_app/widgets/app_scaffold.dart';

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;
  final Duration total;
  MediaState(this.mediaItem, this.position, this.total);
}

class TenoresScreen extends StatefulWidget {
  const TenoresScreen({super.key});

  @override
  State<TenoresScreen> createState() => _TenoresScreenState();
}

class _TenoresScreenState extends State<TenoresScreen> {
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest3<MediaItem?, Duration, Duration?, MediaState>(
          audioHandler.mediaItem,
          AudioService.position,
          audioHandler.mediaItem.map((item) => item?.duration),
          (mediaItem, position, total) =>
              MediaState(mediaItem, position, total ?? Duration.zero));

  @override
  void initState() {
    super.initState();
    _loadAndSetPlaylist();
  }

  void _loadAndSetPlaylist() {
    final currentQueue = audioHandler.queue.value;
    if (currentQueue.isNotEmpty) {
      final currentNaipe = currentQueue.first.extras?['naipe'] as String?;
      if (currentNaipe == 'tenor') {
        print("A playlist de Tenores já está carregada.");
        return;
      }
    }
    
    print("Carregando ou trocando para a playlist dos Tenores...");
    FirebaseFirestore.instance
        .collection('naipes')
        .doc('tenor')
        .collection('musicas')
        .get()
        .then((snapshot) {
      if (!mounted || snapshot.docs.isEmpty) return;
      final musicList = snapshot.docs.map((doc) => Music.fromFirestore(doc)).toList();
      final validMusicList = musicList.where((music) => music.url.isNotEmpty && Uri.tryParse(music.url) != null);
      final mediaItems = validMusicList
          .map((music) => MediaItem(
                id: music.id,
                title: music.titulo,
                extras: {'url': music.url, 'letra': music.letra, 'naipe': 'tenor'},
              ))
          .toList();
      if (mediaItems.isNotEmpty) {
        audioHandler.updatePlaylist(mediaItems);
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showLyricsBottomSheet(BuildContext context, String title, String lyrics) {
     showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF212121),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12.0),
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Nexa')),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(lyrics, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Kit Voz - Tenores',
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/wallpaper.png'), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<MediaState>(
                stream: _mediaStateStream,
                builder: (context, snapshot) {
                  final mediaState = snapshot.data;
                  final mediaItem = mediaState?.mediaItem;
                  final position = mediaState?.position ?? Duration.zero;
                  final total = mediaState?.total ?? Duration.zero;

                  return Column(
                    children: [
                      Image.asset('assets/images/chama_coral.png',
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: MediaQuery.of(context).size.width * 0.7,
                          fit: BoxFit.contain),
                      const SizedBox(height: 10),
                      Text(mediaItem?.title ?? 'Nenhuma música selecionada',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Nexa', color: Colors.white)),
                      const SizedBox(height: 10),
                      Slider(
                          activeColor: Colors.white,
                          inactiveColor: Colors.grey[600],
                          min: 0,
                          max: total.inSeconds.toDouble() > 0 ? total.inSeconds.toDouble() : 1.0,
                          value: position.inSeconds.toDouble().clamp(0.0, total.inSeconds.toDouble()),
                          onChanged: (value) => audioHandler.seek(Duration(seconds: value.toInt()))),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position), style: const TextStyle(color: Colors.white)),
                            Text(_formatDuration(total), style: const TextStyle(color: Colors.white)),
                          ]),
                      const SizedBox(height: 10),
                      StreamBuilder<PlaybackState>(
                        stream: audioHandler.playbackState,
                        builder: (context, snapshot) {
                          final playing = snapshot.data?.playing ?? false;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                                onPressed: audioHandler.skipToPrevious,
                              ),
                              IconButton(
                                icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 64),
                                onPressed: playing ? audioHandler.pause : audioHandler.play,
                              ),
                              IconButton(
                                icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                                onPressed: audioHandler.skipToNext,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(color: Colors.white70),
            Expanded(
              child: StreamBuilder<List<MediaItem>>(
                stream: audioHandler.queue,
                builder: (context, snapshot) {
                  final queue = snapshot.data ?? [];
                  if (queue.isEmpty) return const Center(child: CircularProgressIndicator(color: Colors.white));
                  
                  return ListView.builder(
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final mediaItem = queue[index];
                      return Card(
                        color: Colors.black54,
                        child: StreamBuilder<MediaItem?>(
                          stream: audioHandler.mediaItem,
                          builder: (context, currentItemSnapshot) {
                            final currentMediaItem = currentItemSnapshot.data;
                            final isThisTheSelectedSong = currentMediaItem?.id == mediaItem.id;
                            
                            return ListTile(
                              title: Text(mediaItem.title, style: const TextStyle(color: Colors.white)),
                              trailing: isThisTheSelectedSong
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.lyrics_outlined, color: Colors.white),
                                        onPressed: () {
                                           final lyrics = mediaItem.extras?['letra'] as String?;
                                            if (lyrics != null && lyrics.isNotEmpty) {
                                              _showLyricsBottomSheet(context, mediaItem.title, lyrics);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Letra não disponível para esta música.')),
                                              );
                                            }
                                        },
                                      ),
                                      StreamBuilder<PlaybackState>(
                                        stream: audioHandler.playbackState,
                                        builder: (context, playbackStateSnapshot) {
                                          final isPlaying = playbackStateSnapshot.data?.playing ?? false;
                                          return Icon(
                                            isPlaying ? Icons.equalizer : Icons.pause,
                                            color: Colors.white,
                                          );
                                        },
                                      ),
                                    ],
                                  )
                                : const Icon(Icons.play_arrow, color: Colors.white),
                              onTap: () => audioHandler.skipToQueueItem(index),
                            );
                          },
                        ),
                      );
                    },
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