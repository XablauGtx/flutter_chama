import 'dart:io';
import 'package:flutter/foundation.dart'; // Import necessário para o debugPrint
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart'; // Import necessário para LoopMode
// ignore: unused_import
import 'package:chama_app/models/music.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);
  final _cache = DefaultCacheManager();

  MyAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
  }
  
  Future<Uri> _getArtworkUri() async {
    final tempDir = await getTemporaryDirectory();
    final artworkFile = File('${tempDir.path}/artwork.png');
    
    if (!artworkFile.existsSync()) {
      final byteData = await rootBundle.load('assets/images/chama_coral.png');
      await artworkFile.writeAsBytes(byteData.buffer.asUint8List());
    }
    return artworkFile.uri;
  }

  @override
  // ignore: override_on_non_overriding_member
  Future<void> updatePlaylist(List<MediaItem> mediaItems) async {
    final artworkUri = await _getArtworkUri();
    final processedMediaItems = mediaItems.map((item) {
      return item.copyWith(artUri: artworkUri);
    }).toList();

    await _playlist.clear();
    queue.add([]); 

    final audioSources = <AudioSource>[];
    for (var mediaItem in processedMediaItems) {
      final url = mediaItem.extras!['url'] as String;
      final file = await _cache.getSingleFile(url);
      audioSources.add(AudioSource.uri(Uri.file(file.path), tag: mediaItem));
    }
    
    await _playlist.addAll(audioSources);
    queue.add(processedMediaItems);
    await _player.setAudioSource(_playlist, initialIndex: 0, preload: true);
  }

  // --- NOVO MÉTODO SEGURO PARA `setPitch` ---
  // Adicione esta função à sua classe MyAudioHandler.
  Future<void> setPitch(double pitch) async {
    try {
      // Tenta executar o comando normalmente
      await _player.setPitch(pitch);
    } on MissingPluginException {
      // Se o erro específico acontecer (MissingPluginException), ele será "apanhado" aqui.
      // Em vez de crashar a app, ele apenas imprime um aviso e continua.
      debugPrint("AVISO: A função setPitch não é suportada neste ambiente de build. A ignorar.");
    } catch (e) {
      // Apanha qualquer outro erro inesperado que possa acontecer.
      debugPrint("Ocorreu um erro inesperado ao usar o setPitch: $e");
    }
  }

  // --- FIM DO NOVO MÉTODO ---

  Future<void> cycleRepeatMode() async {
    final currentMode = _player.loopMode;
    final nextMode = switch (currentMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    await _player.setLoopMode(nextMode);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    await _player.seek(Duration.zero, index: index);
    play();
  }
  
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
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
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
