import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:chama_app/widgets/app_scaffold.dart';

// Modelo para representar um membro
class Membro {
  final String id;
  final String nome;
  final String naipe;

  Membro({required this.id, required this.nome, required this.naipe});
}

class ChamadaChamaScreen extends StatefulWidget {
  const ChamadaChamaScreen({super.key});

  @override
  State<ChamadaChamaScreen> createState() => _ChamadaChamaScreenState();
}

class _ChamadaChamaScreenState extends State<ChamadaChamaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
    super.dispose();
  }

  String _getTodayDateKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  /// Registra a presença de um membro existente.
  Future<void> _submitAttendance(Membro membro) async {
    setState(() { _isSubmitting = true; });

    final dataAtual = _getTodayDateKey();

    final existingRecord = await FirebaseFirestore.instance
        .collection('registrosChamada')
        .where('data', isEqualTo: dataAtual)
        .where('nome', isEqualTo: membro.nome)
        .limit(1)
        .get();

    if (existingRecord.docs.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${membro.nome} já registou presença hoje!'), backgroundColor: Colors.orange),
        );
      }
      setState(() { _isSubmitting = false; });
      return;
    }

    try {
      // Garante que o status 'presente' é sempre adicionado
      await FirebaseFirestore.instance.collection('registrosChamada').add({
        'nome': membro.nome,
        'naipe': membro.naipe,
        'data': dataAtual,
        'status': 'presente',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Presença de ${membro.nome} registada!'), backgroundColor: Colors.green),
        );
      }
      
      _tabController.animateTo(1);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao registar presença: $e')));
      }
    } finally {
      if(mounted) setState(() { _isSubmitting = false; });
    }
  }

  /// Mostra um diálogo para o novo membro se registar.
  void _showNewChoristerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return NewChoristerDialog(
          onRegister: (nome, telefone, naipe, nascimento) {
            _registerNewChorister(nome, telefone, naipe, nascimento);
          },
        );
      },
    );
  }

  /// Lógica para registar um novo membro, agora incluindo a data de nascimento.
  Future<void> _registerNewChorister(String nome, String telefone, String naipe, DateTime? nascimento) async {
    setState(() { _isSubmitting = true; });

    try {
      final batch = FirebaseFirestore.instance.batch();
      
      final newMemberRef = FirebaseFirestore.instance.collection('membros').doc();
      batch.set(newMemberRef, {
        'nome': nome,
        'naipe': naipe,
        'telefone': telefone,
        'nascimento': nascimento, // Salva a data de nascimento
      });

      final newAttendanceRef = FirebaseFirestore.instance.collection('registrosChamada').doc();
      batch.set(newAttendanceRef, {
        'nome': nome,
        'naipe': naipe,
        'data': _getTodayDateKey(),
        'status': 'presente',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bem-vindo(a), ${nome}! Registo e presença confirmados.'), backgroundColor: Colors.green),
        );
      }
      _tabController.animateTo(1);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no registo: $e')));
      }
    } finally {
      if (mounted) setState(() { _isSubmitting = false; });
    }
  }

  /// Mostra um diálogo para selecionar um membro de um naipe existente.
  void _showMemberSelectionDialog(String naipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MemberSelectionDialog(
          naipe: naipe,
          onMemberSelected: (membro) {
            Navigator.of(context).pop();
            _submitAttendance(membro);
          },
        );
      },
    );
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
          Tab(icon: Icon(Icons.person_add), text: 'Registar Presença'),
          Tab(icon: Icon(Icons.people), text: 'Ver Presentes'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNaipeSelection(),
          _buildAttendanceList(),
        ],
      ),
    );
  }

  /// Widget que mostra os botões dos naipes e o link para novos coralistas.
  Widget _buildNaipeSelection() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/wallpaper.png'), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  "Selecione seu naipe:", 
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.5,
                    ),
                    itemCount: _naipes.length,
                    itemBuilder: (context, index) {
                        final naipe = _naipes[index];
                        return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF192F3C).withOpacity(0.8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                side: const BorderSide(color: Colors.white24)
                            ),
                            onPressed: () => _showMemberSelectionDialog(naipe),
                            child: Text(naipe, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                        );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _showNewChoristerDialog,
                  child: const Text(
                    "É novo(a) por aqui? Registe-se aqui.",
                    style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
           if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  /// Widget que mostra a lista de presentes agrupada por naipe.
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
            return const Center(child: Text('Ninguém registou presença ainda.', style: TextStyle(color: Colors.white)));
          }

          final records = snapshot.data!.docs;
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
              final nomes = entry.value..sort(); // Ordena os nomes alfabeticamente
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

// --- Diálogo de Seleção para Membros Existentes ---
class MemberSelectionDialog extends StatefulWidget {
  final String naipe;
  final Function(Membro) onMemberSelected;

  const MemberSelectionDialog({
    super.key,
    required this.naipe,
    required this.onMemberSelected,
  });

  @override
  State<MemberSelectionDialog> createState() => _MemberSelectionDialogState();
}

class _MemberSelectionDialogState extends State<MemberSelectionDialog> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF192F3C),
      title: Text('Selecione seu nome em ${widget.naipe}', style: const TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Pesquisar nome...',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white38), borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('membros')
                    .where('naipe', isEqualTo: widget.naipe)
                    .orderBy('nome')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Nenhum membro encontrado neste naipe.', style: TextStyle(color: Colors.white70)));
                  }

                  final members = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['nome']?.toString().toLowerCase() ?? '';
                    return name.contains(_searchQuery);
                  }).toList();
                  
                  if (members.isEmpty) {
                     return const Center(child: Text('Nenhum nome corresponde à sua pesquisa.', style: TextStyle(color: Colors.white70)));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final memberDoc = members[index];
                      final memberData = memberDoc.data() as Map<String, dynamic>;
                      final membro = Membro(
                        id: memberDoc.id,
                        nome: memberData['nome'] ?? 'Nome indisponível',
                        naipe: memberData['naipe'] ?? widget.naipe,
                      );

                      return ListTile(
                        title: Text(membro.nome, style: const TextStyle(color: Colors.white)),
                        onTap: () => widget.onMemberSelected(membro),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}

// --- NOVO DIÁLOGO DE REGISTO ---
class NewChoristerDialog extends StatefulWidget {
  final Function(String nome, String telefone, String naipe, DateTime? nascimento) onRegister;
  const NewChoristerDialog({super.key, required this.onRegister});

  @override
  State<NewChoristerDialog> createState() => _NewChoristerDialogState();
}

class _NewChoristerDialogState extends State<NewChoristerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _nascimentoController = TextEditingController();
  String? _selectedNaipe;
  DateTime? _selectedDate;
  final List<String> _naipes = ['Soprano', 'Contralto', 'Tenor', 'Baixo'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _nascimentoController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedNaipe == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione um naipe.'), backgroundColor: Colors.orange)
        );
        return;
      }
      Navigator.of(context).pop();
      widget.onRegister(
        _nomeController.text.trim(),
        _telefoneController.text.trim(),
        _selectedNaipe!,
        _selectedDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF192F3C),
      title: const Text('Registo de Novo Coralista', style: TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: _nomeController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nome Completo', labelStyle: TextStyle(color: Colors.white70)), validator: (v) => v!.trim().isEmpty ? 'O nome é obrigatório.' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _telefoneController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Telefone', labelStyle: TextStyle(color: Colors.white70)), keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(value: _selectedNaipe, hint: const Text('Selecione o seu naipe', style: TextStyle(color: Colors.white70)), dropdownColor: const Color(0xFF192F3C), style: const TextStyle(color: Colors.white), items: _naipes.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(), onChanged: (v) => setState(() => _selectedNaipe = v), validator: (v) => v == null ? 'O naipe é obrigatório.' : null),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nascimentoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Data de Nascimento', labelStyle: TextStyle(color: Colors.white70), suffixIcon: Icon(Icons.calendar_today, color: Colors.white70)),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
        ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Registar e Confirmar Presença')),
      ],
    );
  }
}
