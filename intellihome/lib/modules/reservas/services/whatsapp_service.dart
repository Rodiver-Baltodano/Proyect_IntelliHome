import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Servicio para enviar mensajes de WhatsApp usando Twilio API
class WhatsAppService {
  final String _accountSid;
  final String _authToken;
  final String _fromNumber;
  final String _countryCode;

  WhatsAppService({
    String? accountSid,
    String? authToken,
    String? fromNumber,
    String? countryCode,
  })  : _accountSid = accountSid ?? dotenv.env['TWILIO_ACCOUNT_SID'] ?? '',
        _authToken = authToken ?? dotenv.env['TWILIO_AUTH_TOKEN'] ?? '',
        _fromNumber = fromNumber ?? dotenv.env['TWILIO_WHATSAPP_FROM'] ?? 'whatsapp:+14155238886',
        _countryCode = countryCode ?? dotenv.env['WHATSAPP_COUNTRY_CODE'] ?? '+506';

  /// Envía un mensaje de WhatsApp usando Twilio API
  Future<WhatsAppResult> enviarMensaje({
    required String telefono,
    required String mensaje,
  }) async {
    try {
      // Validar configuración
      if (_accountSid.isEmpty || _authToken.isEmpty) {
        return WhatsAppResult.error(
          'Configuración de WhatsApp incompleta. Verifica TWILIO_ACCOUNT_SID y TWILIO_AUTH_TOKEN en .env',
        );
      }

      // Formatear número de teléfono
      final telefonoFormateado = _formatearTelefono(telefono);
      
      // URL de la API de Twilio
      final url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$_accountSid/Messages.json',
      );

      // Credenciales en Base64
      final credentials = base64Encode(utf8.encode('$_accountSid:$_authToken'));

      // Realizar petición HTTP
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': _fromNumber,
          'To': 'whatsapp:$telefonoFormateado',
          'Body': mensaje,
        },
      );

      // Procesar respuesta
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ [WhatsApp] Mensaje enviado exitosamente');
        print('📱 [WhatsApp] SID: ${data['sid']}');
        print('📊 [WhatsApp] Estado: ${data['status']}');
        
        return WhatsAppResult.success(
          'Mensaje enviado exitosamente',
          messageSid: data['sid'],
        );
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Error desconocido';
        print('❌ [WhatsApp] Error ${response.statusCode}: $errorMessage');
        
        return WhatsAppResult.error(
          'Error al enviar mensaje: $errorMessage',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ [WhatsApp] Excepción: $e');
      return WhatsAppResult.error('Error de conexión: ${e.toString()}');
    }
  }

  /// Formatea el número de teléfono al formato internacional
  String _formatearTelefono(String telefono) {
    // Limpiar el número (quitar espacios, guiones, etc)
    String numeroLimpio = telefono.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Si ya tiene código de país, retornarlo
    if (numeroLimpio.startsWith('+')) {
      return numeroLimpio;
    }
    
    // Si empieza con el código de país sin +, agregarlo
    if (numeroLimpio.startsWith(_countryCode.substring(1))) {
      return '+$numeroLimpio';
    }
    
    // Agregar código de país
    return '$_countryCode$numeroLimpio';
  }

  /// Envía mensaje de confirmación de reserva
  Future<WhatsAppResult> enviarConfirmacionReserva({
    required String telefono,
    required String nombreUsuario,
    required String reservationId,
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final inicio = '${startDate.day}/${startDate.month}/${startDate.year}';
    final fin = '${endDate.day}/${endDate.month}/${endDate.year}';
    
    final mensaje = '''🏠 *IntelliHome - Confirmación de Reserva*

Hola $nombreUsuario,

✅ Tu reserva ha sido confirmada exitosamente.

📋 *Detalles:*
• Reserva ID: $reservationId
• Propiedad: $propertyId
• Check-in: $inicio
• Check-out: $fin

¡Esperamos que disfrutes tu estadía!

_IntelliHome Team_''';

    return await enviarMensaje(
      telefono: telefono,
      mensaje: mensaje,
    );
  }

  /// Envía mensaje de activación de reserva
  Future<WhatsAppResult> enviarActivacionReserva({
    required String telefono,
    required String nombreUsuario,
    required String propertyId,
  }) async {
    final mensaje = '''🔓 *IntelliHome - Reserva Activada*

Hola $nombreUsuario,

✅ Tu reserva en $propertyId está ahora ACTIVA.

🏠 Ya puedes acceder a los controles domóticos de la propiedad.

¡Disfruta tu estadía!

_IntelliHome Team_''';

    return await enviarMensaje(
      telefono: telefono,
      mensaje: mensaje,
    );
  }

  /// Envía mensaje de finalización de reserva
  Future<WhatsAppResult> enviarFinalizacionReserva({
    required String telefono,
    required String nombreUsuario,
    required String propertyId,
  }) async {
    final mensaje = '''🏁 *IntelliHome - Reserva Finalizada*

Hola $nombreUsuario,

✅ Tu reserva en $propertyId ha finalizado.

⭐ ¿Te gustaría dejar una reseña?

Esperamos verte pronto.

_IntelliHome Team_''';

    return await enviarMensaje(
      telefono: telefono,
      mensaje: mensaje,
    );
  }
}

/// Resultado de operación de WhatsApp
class WhatsAppResult {
  final bool success;
  final String message;
  final String? messageSid;
  final int? statusCode;

  WhatsAppResult._({
    required this.success,
    required this.message,
    this.messageSid,
    this.statusCode,
  });

  factory WhatsAppResult.success(String message, {String? messageSid}) {
    return WhatsAppResult._(
      success: true,
      message: message,
      messageSid: messageSid,
    );
  }

  factory WhatsAppResult.error(String message, {int? statusCode}) {
    return WhatsAppResult._(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    return 'WhatsAppResult(success: $success, message: $message, sid: $messageSid)';
  }
}
