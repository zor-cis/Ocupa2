/// Único lugar donde viven las rutas del API.
///
/// Abre https://ocupa2.ia3x.com/apix/docs, prueba cada endpoint desde ahí,
/// y corrige las constantes marcadas con TODO. Si una ruta cambia, se cambia
/// aquí y nada más se rompe.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://ocupa2.ia3x.com/apix';

  // --- Auth (lo trabaja Persona 1, pero todos necesitan el token) ---
  static const String login = '/auth/login'; // TODO: confirmar en Swagger

  /// Nombre del campo donde viene el token en la respuesta del login.
  /// Puede ser 'token', 'access_token', 'jwt'...
  static const String tokenField = 'token';

  // --- Ofertas (módulo Persona 4) ---
  static const String ofertas = '/ofertas'; // TODO: ¿/jobs? ¿/offers?
  static const String misOfertas = '/ofertas/mias'; // TODO: confirmar

  static String oferta(int id) => '$ofertas/$id';
  static String aplicantesDeOferta(int id) => '$ofertas/$id/aplicaciones';
  static String elegirGanador(int id) => '$ofertas/$id/ganador';

  // --- Pagos (módulo Persona 4) ---
  static const String pagos = '/pagos'; // TODO: confirmar
  static String pagarOferta(int id) => '$ofertas/$id/pago';

  /// Costo fijo de publicar una oferta.
  static const double costoPublicacion = 1.00;
}