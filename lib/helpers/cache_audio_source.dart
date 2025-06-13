// ignore: unused_import
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Esta classe especial estende o StreamAudioSource do just_audio
class LockCachingAudioSource extends StreamAudioSource {
  final Uri _uri;

  LockCachingAudioSource(this._uri, {super.tag});

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    // Usa o cache manager para obter o arquivo
    final file = await DefaultCacheManager().getSingleFile(_uri.toString());

    // Verifica se o arquivo foi baixado/encontrado com sucesso
    if (!file.existsSync()) {
      throw Exception('Falha ao encontrar o arquivo no cache: $_uri');
    }

    // Obtém o tamanho do arquivo
    final fileLength = await file.length();

    // Calcula o range de bytes a ser lido
    start ??= 0;
    end ??= fileLength;

    // Retorna um Stream do arquivo local para o just_audio tocar
    return StreamAudioResponse(
      sourceLength: fileLength,
      contentLength: end - start,
      offset: start,
      stream: file.openRead(start, end),
      contentType: 'audio/mpeg', // Ajuste se seus arquivos não forem MP3
    );
  }
}