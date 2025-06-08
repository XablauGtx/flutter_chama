import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import 'package:chama_app/main.dart';
import 'package:chama_app/models/music.dart';
import 'package:chama_app/widgets/app_scaffold.dart';

class PdfViewerWithCache extends StatefulWidget {
  final String pdfUrl;
  const PdfViewerWithCache({super.key, required this.pdfUrl});

  @override
  State<PdfViewerWithCache> createState() => _PdfViewerWithCacheState();
}

class _PdfViewerWithCacheState extends State<PdfViewerWithCache> {
  late Future<File> _pdfFileFuture;

  @override
  void initState() {
    super.initState();
    _pdfFileFuture = DefaultCacheManager().getSingleFile(widget.pdfUrl);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: _pdfFileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Erro ao carregar PDF: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        return PDFView(filePath: snapshot.data!.path);
      },
    );
  }
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;
  final Duration total;
  MediaState(this.mediaItem, this.position, this.total);
}

class StringsScreen extends StatefulWidget {
  const StringsScreen({super.key});

  @override
  State<StringsScreen> createState() => _StringsScreenState();
}

class _StringsScreenState extends State<StringsScreen> {
  bool _isLoading = true;

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
    const playlistId = 'strings';
    final currentQueue = audioHandler.queue.value;
    if (currentQueue.isNotEmpty) {
      final currentPlaylistId = currentQueue.first.extras?['playlistId'] as String?;
      if (currentPlaylistId == playlistId) {
        if (mounted) setState(() { _isLoading = false; });
        return;
      }
    }
    
    if (mounted) setState(() { _isLoading = true; });
    
    FirebaseFirestore.instance
        .collection('instrumentos')
        .doc(playlistId)
        .collection('musicas')
        .get()
        .then((snapshot) {
          if (!mounted) return;
          final musicList = snapshot.docs.map((doc) => Music.fromFirestore(doc)).toList();
          final validMusicList = musicList.where((music) => music.url.isNotEmpty && Uri.tryParse(music.url) != null);
          final mediaItems = validMusicList
              .map((music) => MediaItem(
                    id: music.id,
                    title: music.titulo,
                    extras: {
                      'url': music.url,
                      'letra': music.letra,
                      'cifraUrl': music.cifraUrl,
                      'playlistId': playlistId,
                    },
                  ))
              .toList();
          if (mediaItems.isNotEmpty) {
            audioHandler.updatePlaylist(mediaItems);
          }
        })
        .whenComplete(() {
          if (mounted) {
            setState(() { _isLoading = false; });
          }
        });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showPdfBottomSheet(BuildContext context, String pdfUrl, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2D2D2D),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12.0),
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: PdfViewerWithCache(pdfUrl: pdfUrl),
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
      title: 'Banda - Strings',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Container(
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
                                final repeatMode = snapshot.data?.repeatMode ?? AudioServiceRepeatMode.none;
                                
                                IconData repeatIcon;
                                Color repeatColor = Colors.white54;
                                if(repeatMode == AudioServiceRepeatMode.all) {
                                  repeatIcon = Icons.repeat;
                                  repeatColor = Colors.white;
                                } else if (repeatMode == AudioServiceRepeatMode.one) {
                                  repeatIcon = Icons.repeat_one;
                                  repeatColor = Colors.white;
                                } else {
                                  repeatIcon = Icons.repeat;
                                }

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      icon: Icon(repeatIcon, color: repeatColor),
                                      onPressed: audioHandler.cycleRepeatMode,
                                    ),
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
                                    IconButton(
                                      icon: const Icon(Icons.shuffle, color: Colors.white54),
                                      onPressed: () {}, 
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
                        if (queue.isEmpty) return const Center(child: Text("Carregando lista de músicas...", style: TextStyle(color: Colors.white)));
                        
                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
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
                                              icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
                                              tooltip: 'Ver Cifra/Partitura',
                                              onPressed: () {
                                                 final cifraUrl = mediaItem.extras?['cifraUrl'] as String?;
                                                  if (cifraUrl != null && cifraUrl.isNotEmpty) {
                                                    _showPdfBottomSheet(context, cifraUrl, mediaItem.title);
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('PDF não disponível para esta música.')),
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