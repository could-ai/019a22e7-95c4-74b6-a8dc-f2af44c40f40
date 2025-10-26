class AdultoMayor {
  final String nombres;
  final String cedula;
  final String fechaNacimiento;
  final String estado;
  final String municipio;
  final String hashIdentificador;
  final int? edad;

  AdultoMayor({
    required this.nombres,
    required this.cedula,
    required this.fechaNacimiento,
    required this.estado,
    required this.municipio,
    required this.hashIdentificador,
    this.edad,
  });
}