import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/escanear_screen.dart';
import 'screens/ver_escaneos_screen.dart';
import 'screens/configuracion_screen.dart';
import 'models/adulto_mayor.dart';
import 'models/escaneo.dart';  // Placeholder para modelo de escaneo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdultoMayorProvider()),
        ChangeNotifierProvider(create: (_) => EscaneoProvider()),  // Simula datos de escaneos
      ],
      child: MaterialApp(
        title: 'App Escáner - Ministerio del Poder Popular para ADULTOS MAYORES',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
          textTheme: const TextTheme(
            headlineMedium: TextStyle(color: Color(0xFF1E40AF), shadows: [Shadow(color: Colors.white, blurRadius: 2.0)]),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/menu': (context) => const MenuScreen(),
          '/registro': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return RegistroScreen(hashPrecompletado: args?['hashPrecompletado']);
          },
          '/escanear': (context) => const EscanearScreen(),
          '/ver-escaneos': (context) => const VerEscaneosScreen(),
          '/configuracion': (context) => const ConfiguracionScreen(),
        },
      ),
    );
  }
}

// Providers simples para simular datos (reemplaza con Supabase cuando conectes)
class AdultoMayorProvider with ChangeNotifier {
  final List<AdultoMayor> _registros = [];  // Lista simulada de adultos mayores
  List<AdultoMayor> get registros => _registros;

  void agregarRegistro(AdultoMayor adulto) {
    _registros.add(adulto);
    notifyListeners();
    // Placeholder: Aquí iría la llamada a API backend para guardar en BD
  }

  AdultoMayor? buscarPorHash(String hash) {
    return _registros.where((a) => a.hashIdentificador == hash).firstOrNull;
  }
}

class EscaneoProvider with ChangeNotifier {
  final List<Escaneo> _escaneos = [];  // Lista simulada de escaneos
  List<Escaneo> get escaneos => _escaneos;

  void agregarEscaneo(Escaneo escaneo) {
    _escaneos.add(escaneo);
    notifyListeners();
    // Placeholder: Aquí iría la llamada a API backend para guardar escaneo en tabla 'escaneos'
  }
}
