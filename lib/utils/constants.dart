class ApiConstants {
  static const String baseUrl = 'https://ocupa2.ia3x.com/apix';

  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String me = '$baseUrl/me';
  static const String updateProfile = '$baseUrl/me/profile';
  static const String updatePassword = '$baseUrl/me/password';

  static const String offers = '$baseUrl/offers';
  static String offerDetail(String id) => '$offers/$id';
  static String applyToOffer(String id) => '$offers/$id/apply';

  static const String videos = '$baseUrl/videos';
  static const String myApplications = '$baseUrl/me/applications';
  static const String experiences = '$baseUrl/me/experiences';
  static const String jobTypes = '$baseUrl/job-types';
  static const String myPayments = '$baseUrl/me/payments';
}