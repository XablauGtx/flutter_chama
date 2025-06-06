// lib/helpers/dialog_helpers.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chama_app/screens/partituras_screen.dart'; // Import da tela de destino

// Esta função agora é pública e pode ser chamada de qualquer lugar do app
void showPasswordDialog(BuildContext context) {
  final passwordController = TextEditingController();
  String? errorText;
  bool isChecking = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF192F3C),
            title: const Text("Acesso Restrito", style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Por favor, insira a senha para acessar as partituras.", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: const TextStyle(color: Colors.white70),
                    errorText: errorText,
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                    focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2)),
                  ),
                  onChanged: (_) {
                    if (errorText != null) {
                      setState(() => errorText = null);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
                onPressed: () => Navigator.pop(dialogContext),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: isChecking
                    ? null
                    : () async {
                        setState(() { isChecking = true; errorText = null; });
                        try {
                          final doc = await FirebaseFirestore.instance.collection('config').doc('senhas').get();
                          final correctPassword = doc.data()?['senha_partituras'];

                          if (correctPassword == null) {
                            setState(() => errorText = "Erro de configuração.");
                            return;
                          }
                          if (passwordController.text == correctPassword) {
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PartiturasScreen()),
                            );
                          } else {
                            setState(() => errorText = "Senha incorreta!");
                          }
                        } catch (e) {
                          setState(() => errorText = "Erro ao verificar senha.");
                          print("Erro ao buscar senha no Firestore: $e");
                        } finally {
                          if (dialogContext.mounted) {
                             setState(() => isChecking = false);
                          }
                        }
                      },
                child: isChecking
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                    : const Text("Entrar", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    },
  );
}