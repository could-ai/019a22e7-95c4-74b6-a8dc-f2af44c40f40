class Escaneo {
  final String hash;
  final DateTime timestamp;
  final String adultoMayorId;  // Simula relación con adultos_mayores

  Escaneo({
    required this.hash,
    required this.timestamp,
    required this.adultoMayorId,
  });
}