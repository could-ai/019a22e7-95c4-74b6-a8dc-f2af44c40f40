import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/adulto_mayor.dart';

class VerEscaneosScreen extends StatelessWidget {
  const VerEscaneosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final escaneos = Provider.of<EscaneoProvider>(context).escaneos;
    final adultoMayorProvider = Provider.of<AdultoMayorProvider>(context, listen: false);

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
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Total de escaneos: ${escaneos.length}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: escaneos.length,
                    itemBuilder: (context, index) {
                      final escaneo = escaneos[index];
                      final adulto = adultoMayorProvider.buscarPorHash(escaneo.adultoMayorId);
                      final formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(escaneo.timestamp);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        elevation: 3,
                        child: ListTile(
                          leading: const Icon(Icons.person_pin, color: Color(0xFF1E40AF), size: 40),
                          title: Text(
                            adulto?.nombres ?? 'Usuario no encontrado',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'C.I: ${adulto?.cedula ?? 'N/A'} - Edad: ${adulto?.edad ?? 'N/A'} años\n'
                            'Hash: ${escaneo.hash}\n'
                            'Fecha: $formattedDate',
                          ),
                          isThreeLine: true,
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
