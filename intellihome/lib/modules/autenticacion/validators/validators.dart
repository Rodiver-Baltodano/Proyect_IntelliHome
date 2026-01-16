/// Clase unificada de validaciones para registro y autenticación.
/// Incluye todas las validaciones necesarias para ambos módulos.
class ValidacionesAutenticacion {
  /// Valida si el nombre y apellidos es válido.
  /// - Debe tener al menos 2 palabras (nombre y apellido)
  /// - Solo letras (incluyendo acentos) y espacios
  static bool esNombreValido(String nombre) {
    final valor = nombre.trim();
    if (valor.isEmpty) return false;

    final partes = valor.split(RegExp(r'\s+'));
    if (partes.length < 2) return false;

    // Permite letras (incluyendo acentos, ñ) y espacios
    final regex = RegExp(r'^[a-zA-Z\s\u00C0-\u00FF]+$');
    return regex.hasMatch(valor);
  }

  /// Valida si el identificador es un correo electrónico válido.
  static bool esEmailValido(String correo) {
    final valor = correo.trim();
    if (valor.isEmpty) return false;

    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(valor);
  }

  /// Valida si el identificador es un teléfono válido.
  /// Acepta 8 dígitos (CR) y variantes con +506 / 506.
  static bool esTelefonoValido(String telefono) {
    var valor = telefono.trim();
    if (valor.isEmpty) return false;

    // Eliminar espacios, guiones, paréntesis
    valor = valor.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Eliminar +
    if (valor.startsWith('+')) {
      valor = valor.substring(1);
    }

    // Eliminar código país 506
    if (valor.startsWith('506') && valor.length == 11) {
      valor = valor.substring(3);
    }

    // Deben quedar exactamente 8 dígitos
    if (valor.length != 8) return false;

    return RegExp(r'^\d{8}$').hasMatch(valor);
  }

  /// Valida si el identificador es un username válido.
  /// Solo letras y números (alfanumérico), 3 a 20 caracteres.
  static bool esUsernameValido(String username) {
    final valor = username.trim();
    if (valor.isEmpty) return false;

    final regex = RegExp(r'^[a-zA-Z0-9]{3,20}$');
    return regex.hasMatch(valor);
  }

  /// Valida si la contraseña es alfanumérica y mínimo 8 caracteres.
  /// Solo letras y números, sin caracteres especiales.
  static bool esContrasenaValida(String contrasena) {
    final valor = contrasena.trim();
    if (valor.isEmpty) return false;

    final regex = RegExp(r'^[a-zA-Z0-9]{8,}$');
    return regex.hasMatch(valor);
  }

  /// Valida si el IBAN tiene un formato válido (básico).
  /// Formato esperado: 2 letras mayúsculas + 2 dígitos + hasta 30 caracteres alfanuméricos
  static bool esIBANValido(String iban) {
    final valor = iban.trim().toUpperCase();
    if (valor.isEmpty) return false;

    final regex = RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]{1,30}$');
    return regex.hasMatch(valor);
  }

  /// Valida si la persona es mayor o igual a 18 años.
  static bool esMayorDeEdad(DateTime fechaNacimiento) {
    final hoy = DateTime.now();
    final fecha18 = DateTime(fechaNacimiento.year + 18, fechaNacimiento.month, fechaNacimiento.day);
    return !fecha18.isAfter(hoy);
  }
}
