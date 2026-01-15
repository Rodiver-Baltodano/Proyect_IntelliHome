// Clase con todos los validadores necesarios
class Validador {
  // Validar que sea alfanumérico (permite espacios, puntos, guiones)
  static bool esAlfanumerico(String valor) {
    final regex = RegExp(r'^[a-zA-Z0-9\s\.\-áéíóúñüÁÉÍÓÚÑÜ]+$');
    return regex.hasMatch(valor);
  }

  // Validar email con formato
  static bool esEmailValido(String email) {
    final regex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  // Validar teléfono (10-15 dígitos)
  static bool esTelefonoValido(String telefono) {
    final regex = RegExp(r'^[0-9\+\-\s]{10,15}$');
    return regex.hasMatch(telefono);
  }

  // Validar IBAN (formato básico)
  static bool esIBANValido(String iban) {
    final regex = RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]{1,30}$');
    return regex.hasMatch(iban);
  }

  // Validar username (alfanumérico, guiones y guiones bajos, 3-20 caracteres)
  static bool esUsernameValido(String username) {
    final regex = RegExp(r'^[a-zA-Z0-9_-]{3,20}$');
    return regex.hasMatch(username);
  }

  // Validar contraseña (mínimo 8 caracteres)
  static bool esContrasenaValida(String contrasena) {
    return contrasena.length >= 8;
  }

  // Validar que nombre tenga al menos 2 palabras (nombre y apellido)
  static bool esNombreValido(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    return partes.length >= 2 && esAlfanumerico(nombre);
  }
}
