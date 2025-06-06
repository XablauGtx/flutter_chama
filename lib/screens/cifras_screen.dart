import 'package:chama_app/screens/pdf_viewer_screen.dart';
import 'package:chama_app/widgets/app_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CifrasScreen extends StatefulWidget {
  const CifrasScreen({super.key});

  @override
  State<CifrasScreen> createState() => _CifrasScreenState();
}

class _CifrasScreenState extends State<CifrasScreen> {
  List<QueryDocumentSnapshot> _allDocs = [];
  List<QueryDocumentSnapshot> _filteredDocs = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
    _searchController.addListener(_filterDocuments);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDocuments);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDocuments() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('cifras').orderBy('titulo').get();
      if (mounted) {
        setState(() {
          _allDocs = snapshot.docs;
          _filteredDocs = snapshot.docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar cifras: $e')),
        );
      }
    }
  }

  void _filterDocuments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDocs = _allDocs.where((doc) {
        final title = (doc.data() as Map<String, dynamic>)['titulo']?.toLowerCase() ?? '';
        return title.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Cifras',
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
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _filteredDocs.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isNotEmpty
                                ? 'Nenhum resultado para "${_searchController.text}"'
                                : 'Nenhuma cifra encontrada.',
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: _filteredDocs.length,
                          itemBuilder: (context, index) {
                            final doc = _filteredDocs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final String title = data['titulo'] ?? 'Título desconhecido';
                            final String url = data['url'] ?? '';

                            return Card(
                              color: const Color(0xFF192F3C).withOpacity(0.8),
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: ListTile(
                                leading: const Icon(Icons.queue_music_outlined, color: Colors.red),
                                title: Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'Nexa')),
                                onTap: () {
                                  if (url.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfViewerScreen(pdfUrl: url, title: title),
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