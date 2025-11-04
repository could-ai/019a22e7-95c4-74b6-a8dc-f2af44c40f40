import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    // Detener la cámara mientras se procesa para evitar escaneos múltiples
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
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Éxito: ${adulto.nombres} encontrado.'), backgroundColor: Colors.green),
      );

      // Navega a la pantalla de escaneos y elimina la actual del stack
      Navigator.popAndPushNamed(context, '/ver-escaneos');
    } else {
      // Hash no encontrado: abrir registro con el hash pre-completado
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hash no registrado. Por favor, complete el registro.'), backgroundColor: Colors.orange),
      );
      Navigator.popAndPushNamed(context, '/registro', arguments: {'hashPrecompletado': hash});
    }
  }

  Future<void> _scanFromImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) return;
      
      // analyzeImage ahora devuelve un BarcodeCapture?, no un booleano.
      final BarcodeCapture? capture = await _controller.analyzeImage(image.path);
      final barcode = capture?.barcodes.firstOrNull;

      if (barcode != null && barcode.rawValue != null) {
        if (_isProcessing) return;
        setState(() {
          _isProcessing = true;
        });
        debugPrint('Código QR detectado desde imagen: ${barcode.rawValue}');
        _procesarEscaneo(barcode.rawValue!);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró código QR en la imagen.')),
          );
        }
      }
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
            icon: const Icon(Icons.image, color: Colors.white),
            onPressed: _scanFromImage,
            tooltip: 'Escanear desde imagen',
          ),
          IconButton(
            icon: ValueListenableBuilder<bool>(
              valueListenable: _controller.torchEnabled,
              builder: (context, state, child) {
                if (state) {
                  return const Icon(Icons.flash_on, color: Colors.yellow);
                } else {
                  return const Icon(Icons.flash_off, color: Colors.white);
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
