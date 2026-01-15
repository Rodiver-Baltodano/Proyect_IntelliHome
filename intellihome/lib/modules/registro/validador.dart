// Clase con todos los validadores necesarios
class Validador {
  // Validar que sea alfanumérico (solo letras y números, permite espacios)
  static bool esAlfanumerico(String valor) {
    final regex = RegExp(r'^[a-zA-Z0-9\s]+$');
    return regex.hasMatch(valor);
  }

  // Validar email con formato
  static bool esEmailValido(String email) {
    final regex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  // Validar teléfono (10-15 dígitos, permite + y -)
  static bool esTelefonoValido(String telefono) {
    final regex = RegExp(r'^[0-9\+\-\s]{10,15}$');
    return regex.hasMatch(telefono);
  }

  // Validar IBAN (formato básico)
  static bool esIBANValido(String iban) {
    final regex = RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]{1,30}$');
    return regex.hasMatch(iban);
  }

  // Validar username (solo letras y números, 3-20 caracteres)
  static bool esUsernameValido(String username) {
    final regex = RegExp(r'^[a-zA-Z0-9]{3,20}$');
    return regex.hasMatch(username);
  }

  // Validar contraseña (mínimo 8 caracteres, solo letras y números)
  static bool esContrasenaValida(String contrasena) {
    if (contrasena.length < 8) {
      return false;
    }
    // Solo letras y números
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(contrasena);
  }

  // Validar que nombre tenga al menos 2 palabras (nombre y apellido)
  static bool esNombreValido(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    return partes.length >= 2 && esAlfanumerico(nombre);
  }
}
