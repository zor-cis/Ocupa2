/// Lee un valor probando varios nombres de campo.
/// Así el modelo aguanta si el API usa snake_case o inglés.
T? _leer<T>(Map<String, dynamic> json, List<String> nombres) {
  for (final n in nombres) {
    final v = json[n];
    if (v != null) return v as T?;
  }
  return null;
}

double _aDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

int _aInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

class OfertaModel {
  final int id;
  final String titulo;
  final String descripcion;
  final String? categoria;
  final double pago;
  final String? ubicacion;
  final double? latitud;
  final double? longitud;
  final String? imagenUrl;
  final String? estado;
  final bool pagada;
  final int totalAplicaciones;
  final int? ganadorId;
  final DateTime? fechaCreacion;

  OfertaModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    this.categoria,
    required this.pago,
    this.ubicacion,
    this.latitud,
    this.longitud,
    this.imagenUrl,
    this.estado,
    this.pagada = false,
    this.totalAplicaciones = 0,
    this.ganadorId,
    this.fechaCreacion,
  });

  factory OfertaModel.fromJson(Map<String, dynamic> json) {
    final fecha =
        _leer<dynamic>(json, ['fecha_creacion', 'fechaCreacion', 'created_at']);
    final lat = _leer<dynamic>(json, ['latitud', 'lat', 'latitude']);
    final lng = _leer<dynamic>(json, ['longitud', 'lng', 'longitude']);
    final ganador = _leer<dynamic>(json, ['ganador_id', 'ganadorId', 'winner_id']);

    return OfertaModel(
      id: _aInt(json['id']),
      titulo: _leer<String>(json, ['titulo', 'title']) ?? '',
      descripcion: _leer<String>(json, ['descripcion', 'description']) ?? '',
      categoria: _leer<String>(json, ['categoria', 'category']),
      pago: _aDouble(_leer<dynamic>(json, ['pago', 'monto', 'salario', 'payment'])),
      ubicacion: _leer<String>(json, ['ubicacion', 'location', 'direccion']),
      latitud: lat == null ? null : _aDouble(lat),
      longitud: lng == null ? null : _aDouble(lng),
      imagenUrl: _leer<String>(json, ['imagen', 'imagen_url', 'image', 'foto']),
      estado: _leer<String>(json, ['estado', 'status']),
      pagada: _leer<dynamic>(json, ['pagada', 'pagado', 'is_paid', 'paid']) == true,
      totalAplicaciones: _aInt(_leer<dynamic>(
          json, ['total_aplicaciones', 'totalAplicaciones', 'aplicaciones_count'])),
      ganadorId: ganador == null ? null : _aInt(ganador),
      fechaCreacion: fecha == null ? null : DateTime.tryParse(fecha.toString()),
    );
  }

  bool get tieneGanador => ganadorId != null;

  String get pagoTexto => 'RD\$ ${pago.toStringAsFixed(0)}';

  String get estadoTexto => pagada ? (estado ?? 'Publicada') : 'Pendiente de pago';
}

class AplicacionModel {
  final int id;
  final int usuarioId;
  final String nombreUsuario;
  final String? fotoUrl;
  final String? mensaje;
  final bool esGanador;
  final DateTime? fecha;

  AplicacionModel({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    this.fotoUrl,
    this.mensaje,
    this.esGanador = false,
    this.fecha,
  });

  factory AplicacionModel.fromJson(Map<String, dynamic> json) {
    // El nombre puede venir plano o dentro de un objeto "usuario".
    final usuario = json['usuario'] as Map<String, dynamic>?;
    final fecha = _leer<dynamic>(json, ['fecha', 'created_at']);

    return AplicacionModel(
      id: _aInt(json['id']),
      usuarioId: _aInt(_leer<dynamic>(json, ['usuario_id', 'usuarioId', 'user_id'])),
      nombreUsuario:
          _leer<String>(json, ['nombre_usuario', 'nombreUsuario', 'nombre']) ??
              _leer<String>(usuario ?? {}, ['nombre', 'name', 'first_name']) ??
              'Usuario',
      fotoUrl: _leer<String>(json, ['foto', 'foto_url', 'avatar']) ??
          _leer<String>(usuario ?? {}, ['foto', 'avatar']),
      mensaje: _leer<String>(json, ['mensaje', 'message', 'comentario']),
      esGanador:
          _leer<dynamic>(json, ['es_ganador', 'esGanador', 'ganador', 'is_winner']) == true,
      fecha: fecha == null ? null : DateTime.tryParse(fecha.toString()),
    );
  }
}

class PagoModel {
  final int id;
  final int? ofertaId;
  final double monto;
  final String? metodo;
  final String? estado;
  final DateTime? fecha;

  PagoModel({
    required this.id,
    this.ofertaId,
    required this.monto,
    this.metodo,
    this.estado,
    this.fecha,
  });

  factory PagoModel.fromJson(Map<String, dynamic> json) {
    final fecha = _leer<dynamic>(json, ['fecha', 'created_at']);
    final oferta = _leer<dynamic>(json, ['oferta_id', 'ofertaId']);

    return PagoModel(
      id: _aInt(json['id']),
      ofertaId: oferta == null ? null : _aInt(oferta),
      monto: _aDouble(_leer<dynamic>(json, ['monto', 'amount'])),
      metodo: _leer<String>(json, ['metodo', 'method']),
      estado: _leer<String>(json, ['estado', 'status']),
      fecha: fecha == null ? null : DateTime.tryParse(fecha.toString()),
    );
  }

  String get montoTexto => 'US\$ ${monto.toStringAsFixed(2)}';
}