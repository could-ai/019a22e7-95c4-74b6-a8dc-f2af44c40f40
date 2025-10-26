import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class VerEscaneosScreen extends StatelessWidget {
  const VerEscaneosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final escaneos = Provider.of<EscaneoProvider>(context).escaneos;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Escaneos'),
        backgroundColor: const Color(0xFFDC2626),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: escaneos.isEmpty
          ? const Center(child: Text('No hay escaneos registrados.'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('Total escaneos: ${escaneos.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: escaneos.length,
                    itemBuilder: (context, index) {
                      final escaneo = escaneos[index];
                      return ListTile(
                        title: Text('Hash: ${escaneo.hash}'),
                        subtitle: Text('Fecha/Hora: ${escaneo.timestamp.toString()}'),
                        // Placeholder: Mostrar nombres, cédula, edad desde BD (usando adultoMayorId)
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}