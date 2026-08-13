class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'El correo es obligatorio';
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Ingresa un correo válido';
    return null;
  }

  static String? notEmpty(String? value, {String field = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$field es obligatorio';
    return null;
  }

  static String? matricula(String? value) {
    if (value == null || value.trim().isEmpty) return 'La matrícula es obligatoria';
    if (value.trim().length < 4) return 'Matrícula inválida';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
    if (value.length < 6) return 'Debe tener al menos 6 caracteres';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? cedula(String? value) {
    if (value == null || value.trim().isEmpty) return 'La cédula es obligatoria';
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 11) return 'La cédula debe tener 11 dígitos';
    return null;
  }
}