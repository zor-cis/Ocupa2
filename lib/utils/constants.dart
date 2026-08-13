class ApiConstants {
  static const String baseUrl = 'https://ocupa2.ia3x.com/apix';

  // --- Auth (Persona 1) ---
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String me = '$baseUrl/me';
  static const String updateProfile = '$baseUrl/me/profile';
  static const String updatePassword = '$baseUrl/me/password';

  // --- Ofertas (Persona 4) ---
  // TODO: confirmar en https://ocupa2.ia3x.com/apix/docs
  static const String ofertas = '$baseUrl/ofertas';
  static const String misOfertas = '$baseUrl/ofertas/mias';

  static String oferta(int id) => '$ofertas/$id';
  static String aplicantesDeOferta(int id) => '$ofertas/$id/aplicaciones';
  static String elegirGanador(int id) => '$ofertas/$id/ganador';

  // --- Pagos (Persona 4) ---
  static const String pagos = '$baseUrl/pagos';
  static String pagarOferta(int id) => '$ofertas/$id/pago';

  /// Costo fijo de publicar una oferta.
  static const double costoPublicacion = 1.00;
}