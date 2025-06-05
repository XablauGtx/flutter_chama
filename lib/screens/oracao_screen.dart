import 'package:chama_app/widgets/app_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <<<--- IMPORT ADICIONADO

class OracaoScreen extends StatefulWidget {
  const OracaoScreen({super.key});

  @override
  State<OracaoScreen> createState() => _OracaoScreenState();
}

class _OracaoScreenState extends State<OracaoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  final _pedidoController = TextEditingController();
  final _nomeController = TextEditingController();
  bool _isAnonymous = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pedidoController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _submitPrayerRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isSending = true; });

      final String nome = _isAnonymous ? 'Anônimo' : _nomeController.text.trim();
      final String pedido = _pedidoController.text.trim();

      try {
        await FirebaseFirestore.instance.collection('pedidos_oracao').add({
          'pedido': pedido,
          'nome': nome.isEmpty ? 'Anônimo' : nome,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _pedidoController.clear();
        _nomeController.clear();
        if(mounted) setState(() { _isAnonymous = false; });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seu pedido de oração foi enviado com fé!')),
        );

        _tabController.animateTo(1);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar pedido: $e')),
        );
      } finally {
        if(mounted) setState(() { _isSending = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Pedidos de Oração',
      // --- CORREÇÃO: USANDO O PARÂMETRO 'bottom' DA APPBAR ---
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.red,
        tabs: const [
          Tab(icon: Icon(Icons.edit), text: 'Fazer Pedido'),
          Tab(icon: Icon(Icons.list_alt), text: 'Ver Pedidos'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPrayerForm(),
          _buildPrayerList(),
        ],
      ),
    );
  }

  Widget _buildPrayerForm() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/wallpaper.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Deixe seu Pedido',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Nexa', fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _pedidoController,
                maxLines: 7,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Escreva seu pedido aqui...',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Por favor, escreva seu pedido.' : null,
              ),
              const SizedBox(height: 16),
              if (!_isAnonymous)
                TextFormField(
                  controller: _nomeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Seu nome (opcional)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              SwitchListTile(
                title: const Text('Permanecer anônimo', style: TextStyle(color: Colors.white)),
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value;
                  });
                },
                activeColor: Colors.red,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSending ? null : _submitPrayerRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSending
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3.0))
                    : const Text('Enviar Pedido de Oração', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerList() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/wallpaper.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pedidos_oracao').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar pedidos.', style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Ainda não há pedidos de oração.', style: TextStyle(color: Colors.white)));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final data = request.data() as Map<String, dynamic>;
              
              final timestamp = data['timestamp'] as Timestamp?;
              final date = timestamp != null
                  ? DateFormat('dd/MM/yyyy \'às\' HH:mm', 'pt_BR').format(timestamp.toDate())
                  : 'Data não disponível';
              
              return Card(
                color: const Color(0xFF192F3C).withOpacity(0.8),
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['pedido'] ?? 'Pedido não informado',
                        style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Por: ${data['nome'] ?? 'Anônimo'}',
                            style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                          ),
                          Text(
                            date,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}