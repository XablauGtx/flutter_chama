// lib/audio_handler.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:chama_app/models/music.dart';
// ADICIONE O IMPORT DO CACHE MANAGER AQUI
import 'package:flutter_cache_manager/flutter_cache_manager.dart';


// A função initAudioService continua a mesma...
Future<MyAudioHandler> initAudioService() async {
  final myAudioHandlerInstance = MyAudioHandler();
  await AudioService.init(
    builder: () => myAudioHandlerInstance,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.channel.audio',
      androidNotificationChannelName: 'Music playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
  return myAudioHandlerInstance;
}


// >>>>> SUBSTITUA SUA CLASSE MyAudioHandler POR ESTA <<<<<
class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);
  final _cache = DefaultCacheManager(); // Instância do gerenciador de cache

  MyAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
  }

  // --- O MÉTODO UPDATEPLAYLIST FOI MODIFICADO PARA LIDAR COM O CACHE ---
  @override
  Future<void> updatePlaylist(List<MediaItem> mediaItems) async {
    // Limpa a playlist antiga no player e na UI
    await _playlist.clear();
    queue.add([]); // Limpa a fila na UI

    // Lista para guardar as fontes de áudio (agora com cache)
    final audioSources = <AudioSource>[];

    // Faz um loop para processar cada música
    for (var mediaItem in mediaItems) {
      final url = mediaItem.extras!['url'] as String;
      
      // Pede ao cache manager o arquivo. Ele baixa se não existir, ou retorna o local se já existir.
      final file = await _cache.getSingleFile(url);
      
      // Adiciona a fonte de áudio apontando para o ARQUIVO LOCAL
      audioSources.add(
        AudioSource.uri(
          Uri.file(file.path), // Usa o caminho do arquivo no celular
          tag: mediaItem,
        ),
      );
    }
    
    // Adiciona todas as fontes de áudio locais à playlist do player
    await _playlist.addAll(audioSources);

    // Atualiza a fila na UI com os MediaItems originais
    queue.add(mediaItems);
    
    // Inicia o player com a nova playlist
    await _player.setAudioSource(_playlist, initialIndex: 0, preload: true);
  }

  // O método _createAudioSource não é mais necessário
  // AudioSource _createAudioSource(MediaItem mediaItem) { ... }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    await _player.seek(Duration.zero, index: index);
    play();
  }

  // ... O resto da sua classe (play, pause, seek, listeners, etc.) continua igual ...
  // (O código abaixo não foi alterado)

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();
  
  @override
  Future<void> stop() async {
    await _player.stop();
    await playbackState.firstWhere((state) => state.processingState == AudioProcessingState.idle);
  }
  
  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    }, onError: (Object e, StackTrace st) {
      print('PLAYER ERROR: Um erro ocorreu no stream do player: $e');
    });
  }
  
  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }
  
  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      mediaItem.add(playlist[index]);
    });
  }
}