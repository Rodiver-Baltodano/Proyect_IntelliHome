/// Clase de utilidades para validar datos de autenticación.
/// NO contiene lógica de negocio, solo validaciones de formato.
class ValidacionesAutenticacion {
  /// Valida si el identificador es un correo electrónico válido.
  static bool esCorreoValido(String correo) {
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
  /// Permite letras, números, punto y guion bajo.
  /// Longitud: 3 a 20 caracteres.
  static bool esUsernameValido(String username) {
    final valor = username.trim();
    if (valor.isEmpty) return false;

    final regex = RegExp(r'^[a-zA-Z0-9._]{3,20}$');
    return regex.hasMatch(valor);
  }

  /// Valida si la contraseña es alfanumérica y mínimo 8 caracteres.
  static bool esContrasenaValida(String contrasena) {
    final valor = contrasena.trim();
    if (valor.isEmpty) return false;

    final regex = RegExp(r'^[a-zA-Z0-9]{8,}$');
    return regex.hasMatch(valor);
  }
}
