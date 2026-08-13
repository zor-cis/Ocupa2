class ApiConstants {
  static const String baseUrl = 'https://ocupa2.ia3x.com/apix';

  // --- Auth (Persona 1) ---
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String me = '$baseUrl/me';
  static const String updateProfile = '$baseUrl/me/profile';
  static const String updatePassword = '$baseUrl/me/password';

  // --- Catálogo (compartido) ---
  static const String jobTypes = '$baseUrl/job-types';

  // --- Subida de imágenes (compartido) ---
  static const String uploads = '$baseUrl/uploads';

  // --- Ofertas (Persona 4) ---
  static const String ofertas = '$baseUrl/offers';
  static const String misOfertas = '$baseUrl/me/offers';

  static String oferta(String id) => '$ofertas/$id';
  static String desactivarOferta(String id) => '$ofertas/$id/deactivate';
  static String aplicantesDeOferta(String id) => '$ofertas/$id/applications';

  // TODO: no aparece en el Swagger. Preguntar al profesor si existe.
  static String elegirGanador(String id) => '$ofertas/$id/winner';

  // --- Pagos (Persona 4) ---
  static const String pagos = '$baseUrl/payments';
  static const String misPagos = '$baseUrl/me/payments';

  /// Costo fijo de publicar una oferta (pasarela simulada).
  static const double costoPublicacion = 1.00;
  static const String monedaPago = 'USD';

  /// Tarjetas de prueba de la pasarela simulada.
  static const String tarjetaAprobada = '4242424242424242';
  static const String tarjetaRechazada = '4000000000000002';
}