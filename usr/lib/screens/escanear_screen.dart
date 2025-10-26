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
  MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],  // Solo QR
    detectionSpeed: DetectionSpeed.normal,
  );
  bool _isActive = false;
  int _intentos = 0;

  @override
  void initState() {
    super.initState();
    controller.start();  // Inicia cámara con permisos automáticos
    setState(() => _isActive = true);
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String code = barcode.rawValue ?? '';
      debugPrint('Escaneado: $code');  // Log para depuración
      setState(() => _intentos++);
      _procesarEscaneo(code);
    }
  }

  void _procesarEscaneo(String hash) {
    final provider = Provider.of<AdultoMayorProvider>(context, listen: false);
    final adulto = provider.buscarPorHash(hash);
    if (adulto != null) {
      // Hash encontrado: Mostrar validación y guardar escaneo simulado
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Validación Exitosa'),
          content: Text('Hash encontrado: ${adulto.nombres}, Cédula: ${adulto.cedula}, Edad: ${adulto.edad}'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      final escaneoProvider = Provider.of<EscaneoProvider>(context, listen: false);
      escaneoProvider.agregarEscaneo(Escaneo(
        hash: hash,
        timestamp: DateTime.now(),
        adultoMayorId: adulto.hashIdentificador,  // Simula ID
      ));
      // Placeholder: Guardar en BD via API
    } else {
      // Hash no encontrado: Abrir registro con hash pre-completado
      Navigator.pushNamed(context, '/registro', arguments: {'hashPrecompletado': hash});
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
            icon: Icon(_isActive ? Icons.flash_on : Icons.flash_off),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Text('Activo: $_isActive, Intentos: $_intentos', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}