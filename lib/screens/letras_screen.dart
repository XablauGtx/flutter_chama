import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: unused_import
import 'package:share_plus/share_plus.dart';
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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchAllSongs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchAllSongs() async {
    final snapshot = await FirebaseFirestore.instance.collection('Letras').orderBy('titulo').get();
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

  Widget _buildHighlightedText(String text, String query) {
    // Pega a cor do texto principal do tema atual
    final defaultStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface, 
      fontWeight: FontWeight.bold, 
      fontFamily: 'Nexa'
    );
    // Cor de destaque (pode ser personalizada para cada tema também)
    final highlightStyle = const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontFamily: 'Nexa');

    if (query.isEmpty) {
      return Text(text, style: defaultStyle);
    }
    // ... (lógica de destacar texto continua a mesma)
    final spans = <TextSpan>[];
    int start = 0;
    int indexOfQuery;

    while ((indexOfQuery = text.toLowerCase().indexOf(query.toLowerCase(), start)) != -1) {
      if (indexOfQuery > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfQuery), style: defaultStyle));
      }
      spans.add(TextSpan(text: text.substring(indexOfQuery, indexOfQuery + query.length), style: highlightStyle));
      start = indexOfQuery + query.length;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: defaultStyle));
    }
    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Letras',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              // Usa a cor de texto do tema
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Pesquisar por título...',
                // Usa a cor de texto secundária do tema
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
                filled: true,
                // Usa a cor dos cards do tema
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurface),
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
                ? const Center(child: CircularProgressIndicator())
                : _filteredSongs.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isNotEmpty ? 'Nenhum resultado para "${_searchController.text}"' : 'Nenhuma letra encontrada.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _filteredSongs.length,
                        itemBuilder: (context, index) {
                          final music = _filteredSongs[index];
                          return Card(
                            // Usa a cor de card definida no tema
                            color: Theme.of(context).cardColor.withOpacity(0.9),
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ExpansionTile(
                              title: _buildHighlightedText(music.titulo, _searchController.text),
                              iconColor: Theme.of(context).iconTheme.color,
                              collapsedIconColor: Theme.of(context).iconTheme.color,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                  child: Text(
                                    music.letra!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.copy, color: Theme.of(context).iconTheme.color),
                                      tooltip: 'Copiar Letra',
                                      onPressed: () { /* ... */ },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.share, color: Theme.of(context).iconTheme.color),
                                      tooltip: 'Compartilhar Letra',
                                      onPressed: () { /* ... */ },
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
    );
  }
}
