import 'dart:async'; // Import para usar o Timer (debounce)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import para usar o Clipboard (copiar)
import 'package:share_plus/share_plus.dart'; // Import do pacote de compartilhamento
import 'package:chama_app/models/music.dart';
import 'package:chama_app/widgets/app_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LetrasScreen extends StatefulWidget {
  const LetrasScreen({super.key});

  @override
  State<LetrasScreen> createState() => _LetrasScreenState();
}

class _LetrasScreenState extends State<LetrasScreen> {
  List<Music> _allSongs = [];
  List<Music> _filteredSongs = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  Timer? _debounce; // --- SUGESTÃO 2: Timer para o debounce da pesquisa ---

  @override
  void initState() {
    super.initState();
    _fetchAllSongs();
    // Modificado para usar o debounce
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel(); // Cancela o timer ao sair da tela
    super.dispose();
  }

  Future<void> _fetchAllSongs() async {
    final snapshot = await FirebaseFirestore.instance.collection('Letras').get();
    final songs = snapshot.docs
        .map((doc) => Music.fromFirestore(doc))
        .where((music) => music.letra != null && music.letra!.isNotEmpty)
        .toList();

    songs.sort((a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));

    if (mounted) {
      setState(() {
        _allSongs = songs;
        _filteredSongs = songs;
        _isLoading = false;
      });
    }
  }

  // --- SUGESTÃO 2: Lógica do Debounce ---
  // Só chama o filtro 300ms depois que o usuário para de digitar
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterSongs();
    });
  }

  void _filterSongs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSongs = _allSongs.where((song) {
        return song.titulo.toLowerCase().contains(query);
      }).toList();
    });
  }

  // --- SUGESTÃO 1: Função para destacar o texto da pesquisa ---
  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Nexa'));
    }

    final spans = <TextSpan>[];
    int start = 0;
    int indexOfQuery;

    while ((indexOfQuery = text.toLowerCase().indexOf(query.toLowerCase(), start)) != -1) {
      if (indexOfQuery > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfQuery), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Nexa')));
      }
      spans.add(TextSpan(
        text: text.substring(indexOfQuery, indexOfQuery + query.length),
        style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontFamily: 'Nexa'), // Destaque em amarelo
      ));
      start = indexOfQuery + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Nexa')));
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Letras',
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/wallpaper.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Pesquisar por título...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xFF192F3C).withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _filteredSongs.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isNotEmpty ? 'Nenhum resultado para "${_searchController.text}"' : 'Nenhuma letra encontrada.',
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: _filteredSongs.length,
                          itemBuilder: (context, index) {
                            final music = _filteredSongs[index];
                            return Card(
                              color: const Color(0xFF192F3C).withOpacity(0.8),
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ExpansionTile(
                                // --- SUGESTÃO 1: Título com destaque ---
                                title: _buildHighlightedText(music.titulo, _searchController.text),
                                iconColor: Colors.white70,
                                collapsedIconColor: Colors.white70,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                    child: Text(
                                      music.letra!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                                    ),
                                  ),
                                  // --- SUGESTÃO 3: BOTÕES DE COPIAR E COMPARTILHAR ---
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.copy, color: Colors.white70),
                                        tooltip: 'Copiar Letra',
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: music.letra!));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Letra copiada para a área de transferência!')),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.share, color: Colors.white70),
                                        tooltip: 'Compartilhar Letra',
                                        onPressed: () {
                                          Share.share('Letra de "${music.titulo}":\n\n${music.letra!}');
                                        },
                                      ),
                                    ],
                                  )
                                ],
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