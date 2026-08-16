class ApiConstants {
  static const String baseUrl = 'https://ocupa2.ia3x.com/apix';
  // --- Auth (Persona 1) ---
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String me = '$baseUrl/me';
  static const String updateProfile = '$baseUrl/me/profile';
  static const String updatePassword = '$baseUrl/me/password';
  // --- Catalogo (compartido) ---
  static const String jobTypes = '$baseUrl/job-types';
  // --- Subida de imagenes (compartido) ---
  static const String uploads = '$baseUrl/uploads';
  // --- Ofertas: base compartida ---
  static const String offers = '$baseUrl/offers';
  static String offerDetail(String id) => '$offers/$id';
  // --- Explorar y aplicar (Persona 3) ---
  static String applyToOffer(String id) => '$offers/$id/apply';
  static const String myApplications = '$baseUrl/me/applications';
  static const String myLikes = '$baseUrl/me/likes';
  // --- Videos / experiencias (develop) ---
  static const String videos = '$baseUrl/videos';
  static const String experiences = '$baseUrl/me/experiences';
  // --- Publicar y administrar (Persona 4) ---
  static const String ofertas = offers;
  static const String misOfertas = '$baseUrl/me/offers';
  static String oferta(String id) => offerDetail(id);
  static String desactivarOferta(String id) => '$offers/$id/deactivate';
  static String aplicantesDeOferta(String id) => '$offers/$id/applications';
  // TODO: no aparece en el Swagger. Preguntar al profesor si existe.
  static String elegirGanador(String id) => '$offers/$id/winner';
  // --- Pagos (Persona 4) ---
  static const String pagos = '$baseUrl/payments';
  static const String misPagos = '$baseUrl/me/payments';
  static const String myPayments = '$baseUrl/me/payments'; // duplicado de misPagos, revisar cuál usar
  /// Costo fijo de publicar una oferta (pasarela simulada).
  static const double costoPublicacion = 1.00;
  static const String monedaPago = 'USD';
  /// Tarjetas de prueba de la pasarela simulada.
  static const String tarjetaAprobada = '4242424242424242';
  static const String tarjetaRechazada = '4000000000000002';
}