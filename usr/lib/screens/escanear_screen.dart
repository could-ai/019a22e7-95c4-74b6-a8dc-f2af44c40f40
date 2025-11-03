import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/escaneo.dart';

class EscanearScreen extends StatefulWidget {
  const EscanearScreen({super.key});

  @override
  State<EscanearScreen> createState() => _EscanearScreenState();
}

class _EscanearScreenState extends State<EscanearScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
  );
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller.start();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode != null && barcode.rawValue != null) {
      setState(() {
        _isProcessing = true;
      });
      debugPrint('Código QR detectado: ${barcode.rawValue}');
      _procesarEscaneo(barcode.rawValue!);
    }
  }

  void _procesarEscaneo(String hash) {
    // Pausa el scanner para evitar múltiples detecciones
    _controller.stop();

    final adultoProvider = Provider.of<AdultoMayorProvider>(context, listen: false);
    final adulto = adultoProvider.buscarPorHash(hash);

    if (adulto != null) {
      // Hash encontrado: guardar escaneo y navegar a la lista de escaneos
      final escaneoProvider = Provider.of<EscaneoProvider>(context, listen: false);
      escaneoProvider.agregarEscaneo(Escaneo(
        hash: hash,
        timestamp: DateTime.now(),
        adultoMayorId: adulto.hashIdentificador,
      ));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Éxito: ${adulto.nombres} encontrado.'), backgroundColor: Colors.green),
      );

      // Navega a la pantalla de escaneos y elimina la actual del stack
      Navigator.popAndPushNamed(context, '/ver-escaneos');
    } else {
      // Hash no encontrado: abrir registro con el hash pre-completado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hash no registrado. Por favor, complete el registro.'), backgroundColor: Colors.orange),
      );
      Navigator.popAndPushNamed(context, '/registro', arguments: {'hashPrecompletado': hash});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
        backgroundColor: const Color(0xFFDC2626),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.white);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            overlay: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                  child: Text(
                'Apunte al código QR',
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
