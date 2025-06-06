import 'package:chama_app/widgets/app_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChamadaChamaScreen extends StatefulWidget {
  const ChamadaChamaScreen({super.key});

  @override
  State<ChamadaChamaScreen> createState() => _ChamadaChamaScreenState();
}

class _ChamadaChamaScreenState extends State<ChamadaChamaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  String? _selectedNaipe;
  bool _isNewChorister = false;
  bool _isSubmitting = false;

  final List<String> _naipes = ['Soprano', 'Contralto', 'Tenor', 'Baixo'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  String _getTodayDateKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _submitAttendance() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedNaipe == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione seu naipe.'), backgroundColor: Colors.orange),
        );
        return;
      }

      setState(() { _isSubmitting = true; });

      final nome = _nomeController.text.trim();
      final dataAtual = _getTodayDateKey();

      // Verifica se a presença já foi registrada
      final existingRecord = await FirebaseFirestore.instance
          .collection('registrosChamada')
          .where('data', isEqualTo: dataAtual)
          .where('nome', isEqualTo: nome)
          .limit(1)
          .get();

      if (existingRecord.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Você já registrou sua presença hoje!'), backgroundColor: Colors.orange),
        );
        setState(() { _isSubmitting = false; });
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('registrosChamada').add({
          'nome': nome,
          'naipe': _selectedNaipe,
          'data': dataAtual,
          'timestamp': FieldValue.serverTimestamp(),
          'novoCoralista': _isNewChorister,
          'telefone': _isNewChorister ? _telefoneController.text.trim() : '',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Presença registrada com sucesso!'), backgroundColor: Colors.green),
        );

        _nomeController.clear();
        _telefoneController.clear();
        setState(() {
          _selectedNaipe = null;
          _isNewChorister = false;
        });
        _tabController.animateTo(1);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao registrar presença: $e')));
      } finally {
        if(mounted) setState(() { _isSubmitting = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Chamada do Ensaio',
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.red,
        tabs: const [
          Tab(icon: Icon(Icons.person_add), text: 'Registrar Presença'),
          Tab(icon: Icon(Icons.people), text: 'Ver Presentes'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRegistrationForm(),
          _buildAttendanceList(),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/wallpaper.png'), fit: BoxFit.cover),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Registro de Presença',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Nexa', fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'Seu nome completo', /* ... */),
                validator: (value) => value == null || value.trim().isEmpty ? 'O nome é obrigatório.' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedNaipe,
                hint: const Text('Selecione seu naipe', style: TextStyle(color: Colors.white70)),
                dropdownColor: const Color(0xFF192F3C),
                style: const TextStyle(color: Colors.white),
                items: _naipes.map((naipe) => DropdownMenuItem(value: naipe, child: Text(naipe))).toList(),
                onChanged: (value) => setState(() => _selectedNaipe = value),
                decoration: InputDecoration( /* ... */ ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Sou novo(a) coralista', style: TextStyle(color: Colors.white)),
                value: _isNewChorister,
                onChanged: (value) => setState(() => _isNewChorister = value!),
                activeColor: Colors.red,
                checkColor: Colors.white,
                tileColor: Colors.black.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              if (_isNewChorister) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefoneController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: 'Seu telefone (opcional)', /*...*/),
                  keyboardType: TextInputType.phone,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text('Registrar Minha Presença', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/wallpaper.png'), fit: BoxFit.cover),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('registrosChamada')
            .where('data', isEqualTo: _getTodayDateKey())
            .orderBy('naipe').orderBy('nome')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Ninguém registrou presença ainda.', style: TextStyle(color: Colors.white)));
          }

          final records = snapshot.data!.docs;
          // Agrupando por naipe
          final Map<String, List<String>> groupedByNaipe = {};
          for (var record in records) {
            final data = record.data() as Map<String, dynamic>;
            final naipe = data['naipe'] as String;
            final nome = data['nome'] as String;
            groupedByNaipe.putIfAbsent(naipe, () => []).add(nome);
          }
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: groupedByNaipe.entries.map((entry) {
              final naipe = entry.key;
              final nomes = entry.value;
              return Card(
                color: const Color(0xFF192F3C).withOpacity(0.9),
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text('$naipe (${nomes.length})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  iconColor: Colors.white70,
                  collapsedIconColor: Colors.white70,
                  children: nomes.map((nome) => ListTile(
                    title: Text(nome, style: const TextStyle(color: Colors.white)),
                    leading: const Icon(Icons.person, color: Colors.white70),
                  )).toList(),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}