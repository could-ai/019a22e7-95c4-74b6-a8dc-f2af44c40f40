import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/adulto_mayor.dart';
import '../main.dart';  // Para acceder a AdultoMayorProvider

class RegistroScreen extends StatefulWidget {
  final String? hashPrecompletado;
  const RegistroScreen({super.key, this.hashPrecompletado});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _fechaController = TextEditingController();
  final _estadoController = TextEditingController();
  final _municipioController = TextEditingController();
  final _hashController = TextEditingController();
  int? _edad;

  @override
  void initState() {
    super.initState();
    if (widget.hashPrecompletado != null) {
      _hashController.text = widget.hashPrecompletado!;
    }
  }

  void _calcularEdad() {
    if (_fechaController.text.isNotEmpty) {
      try {
        final fecha = DateFormat('dd/MM/yyyy').parse(_fechaController.text);
        final hoy = DateTime.now();
        _edad = hoy.year - fecha.year - (hoy.month < fecha.month || (hoy.month == fecha.month && hoy.day < fecha.day) ? 1 : 0);
        setState(() {});
      } catch (e) {
        _edad = null;
      }
    }
  }

  void _registrar() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AdultoMayorProvider>(context, listen: false);
      // Simular unicidad (en BD real, validar via API)
      if (provider.buscarPorHash(_hashController.text) != null || provider.registros.any((a) => a.cedula == _cedulaController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cédula o hash ya existe.')));
        return;
      }
      final adulto = AdultoMayor(
        nombres: _nombresController.text,
        cedula: _cedulaController.text,
        fechaNacimiento: _fechaController.text,
        estado: _estadoController.text,
        municipio: _municipioController.text,
        hashIdentificador: _hashController.text,
        edad: _edad,
      );
      provider.agregarRegistro(adulto);
      // Placeholder: Llamada a API para guardar (convierte fecha a YYYY-MM-DD)
      // Ejemplo: api.registrar(adulto.copyWith(fechaNacimiento: DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_fechaController.text))));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro exitoso.')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Adulto Mayor'),
        backgroundColor: const Color(0xFFDC2626),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(  // Para manejo del teclado
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombresController,
                decoration: const InputDecoration(labelText: 'Nombres y Apellidos'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _cedulaController,
                decoration: const InputDecoration(labelText: 'Cédula'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Requerido';
                  }
                  // La expresión regular anterior era incorrecta.
                  // Esta valida que solo contenga números y tenga al menos 7 dígitos.
                  if (v.length < 7 || !RegExp(r'^\d+$').hasMatch(v)) {
                    return 'Solo números, mínimo 7 dígitos';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fechaController,
                decoration: const InputDecoration(labelText: 'Fecha de Nacimiento (DD/MM/YYYY)'),
                onChanged: (_) => _calcularEdad(),
                validator: (v) {
                  if (v!.isEmpty) return 'Requerido';
                  try { DateFormat('dd/MM/yyyy').parse(v); } catch (e) { return 'Formato inválido'; }
                  return null;
                },
              ),
              if (_edad != null) Text('Edad: $_edad años', style: const TextStyle(color: Color(0xFF1E40AF))),
              TextFormField(
                controller: _estadoController,
                decoration: const InputDecoration(labelText: 'Estado'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _municipioController,
                decoration: const InputDecoration(labelText: 'Municipio'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _hashController,
                decoration: const InputDecoration(labelText: 'Hash Identificador'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registrar,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
