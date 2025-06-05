import 'package:cloud_firestore/cloud_firestore.dart';

class Music {
  final String id;
  final String titulo;
  final String url;
  final String? letra;

  Music({
    required this.id,
    required this.titulo,
    required this.url,
    this.letra,
  });

  factory Music.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Music(
      id: doc.id,
      titulo: data['titulo'] ?? 'Música desconhecida',
      url: data['url'] ?? '',
      letra: data['letra'],
    );
  }
}