// lib/screens/pdf_viewer_screen.dart

// ignore: unused_import
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:chama_app/widgets/app_scaffold.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _localPdfPath;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  // Usa o cache manager para baixar o PDF e salvar localmente
  Future<void> _loadPdf() async {
    try {
      final file = await DefaultCacheManager().getSingleFile(widget.pdfUrl);
      if (mounted) {
        setState(() {
          _localPdfPath = file.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar o PDF: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title, // Mostra o título da cifra/partitura
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : _error != null
                ? Text(_error!, style: const TextStyle(color: Colors.red))
                : _localPdfPath != null
                    ? PDFView(
                        filePath: _localPdfPath,
                        enableSwipe: true,
                        swipeHorizontal: false,
                        autoSpacing: false,
                        pageFling: true,
                      )
                    : const Text('Não foi possível carregar o PDF.', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}