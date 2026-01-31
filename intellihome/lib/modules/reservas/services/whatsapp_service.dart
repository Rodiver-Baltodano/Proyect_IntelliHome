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
      
      print('  [WhatsApp] Iniciando envío...');
      print('   Account SID: ${_accountSid.substring(0, 6)}...');
      print('   Desde: $_fromNumber');
      print('   Para: whatsapp:$telefonoFormateado');
      
      // URL de la API de Twilio
      final url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$_accountSid/Messages.json',
      );

      // Credenciales en Base64
      final credentials = base64Encode(utf8.encode('$_accountSid:$_authToken'));

      // Realizar petición HTTP con timeout
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
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: La petición tardó más de 30 segundos');
        },
      );

      // Procesar respuesta
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print(' [WhatsApp] Mensaje enviado exitosamente');
        print(' [WhatsApp] SID: ${data['sid']}');
        print(' [WhatsApp] Estado: ${data['status']}');
        print(' [WhatsApp] Precio: ${data['price'] ?? 'N/A'} ${data['price_unit'] ?? ''}');
        
        return WhatsAppResult.success(
          'Mensaje enviado exitosamente',
          messageSid: data['sid'],
        );
      } else {
        // Intentar decodificar el error
        String errorMessage = 'Error desconocido';
        String? errorCode;
        
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
          errorCode = errorData['code']?.toString();
          
          // Logs detallados del error
          print(' [WhatsApp] Error ${response.statusCode}');
          print('   Código: ${errorCode ?? 'N/A'}');
          print('   Mensaje: $errorMessage');
          
          if (errorData['more_info'] != null) {
            print('   Más info: ${errorData['more_info']}');
          }
        } catch (e) {
          print(' [WhatsApp] Error ${response.statusCode}: No se pudo parsear respuesta');
          print('   Respuesta raw: ${response.body}');
        }
        
        return WhatsAppResult.error(
          errorCode != null 
            ? 'Error $errorCode: $errorMessage'
            : 'Error al enviar mensaje: $errorMessage',
          statusCode: response.statusCode,
        );
      }
    } on Exception catch (e) {
      print(' [WhatsApp] Excepción: $e');
      return WhatsAppResult.error('Error de conexión: ${e.toString()}');
    } catch (e) {
      print(' [WhatsApp] Error inesperado: $e');
      return WhatsAppResult.error('Error inesperado: ${e.toString()}');
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
    required String propertyName,
    required DateTime envio,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final inicio = '${startDate.day}/${startDate.month}/${startDate.year}';
    final fin = '${endDate.day}/${endDate.month}/${endDate.year}';
    
    final mensaje = '''🏠 *IntelliHome - Confirmación de Reserva*

Hola $nombreUsuario, $envio

✅ Tu reserva ha sido confirmada exitosamente.

📋 *Detalles:*
• Número de Reserva: $reservationId
• Propiedad: $propertyName
• Check-in: $inicio a las 3:00 PM
• Check-out: $fin a las 11:00 AM

¡Esperamos que disfrutes tu estadía!

_IntelliHome Team_''';

    return await enviarMensaje(
      telefono: telefono,
      mensaje: mensaje,
    );
  }

  /// Envía mensaje de alerta de incendio al numero del usuario
  Future<WhatsAppResult> enviarNotificacionIncendio({
    required String telefono,
    required String nombreUsuario,
    required DateTime horadesatre,
    required String nombreCasa,
    required String propertyId,
  }) async {
    final mensaje = '''🔥*IntelliHome - Alerta de Incendio*

Hola $nombreUsuario,${horadesatre.day.toString().padLeft(2, '0')}/${horadesatre.month.toString().padLeft(2, '0')}/${horadesatre.year.toString().padLeft(4, '0')}/${horadesatre.hour.toString().padLeft(2, '0')}:${horadesatre.minute.toString().padLeft(2, '0')},

 Se ha detectado una alerta de incendio en $propertyId,$nombreCasa.

 Por favor, toma las precauciones necesarias y sigue las instrucciones de seguridad.
 Mantenerse alejado del área afectada y buscar una ruta de salida segura. No dudes en
 llamar a los servicios de emergencia si es necesario.

_IntelliHome Team_''';

    return await enviarMensaje(
      telefono: telefono,
      mensaje: mensaje,
    );
  }

  /// Envíar alerta de sismo al numero del usuario
  Future<WhatsAppResult> enviarNotificacionSismo({
    required String telefono,
    required String nombreUsuario,
    required DateTime horadesatre,
    required String nombreCasa,
    required String propertyId,
  }) async {
    final mensaje = '''🫨*IntelliHome - Alerta de Sismo*

Hola $nombreUsuario,${horadesatre.day.toString().padLeft(2, '0')}/${horadesatre.month.toString().padLeft(2, '0')}/${horadesatre.year.toString().padLeft(4, '0')}/${horadesatre.hour.toString().padLeft(2, '0')}:${horadesatre.minute.toString().padLeft(2, '0')},

  Hemos detectado un sismo en $propertyId,$nombreCasa.
  Por favor, mantén la calma y sigue las instrucciones de seguridad.
  Asegúrate de estar en un lugar seguro y alejado de objetos que puedan caer
  o causar daño. Si es necesario, evacua el área siguiendo la ruta de emergencia
  establecidas en la propiedad.

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
