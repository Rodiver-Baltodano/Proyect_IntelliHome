import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';

/// Servicio para enviar códigos de recuperación por email
class EmailService {
  /// Envía código de recuperación al email del usuario
  static Future<bool> enviarCodigoRecuperacion({
    required String email,
    required String codigo,
    required String nombreUsuario,
  }) async {
    try {
      final gmailEmail = dotenv.env['GMAIL_EMAIL'];
      final gmailPassword = dotenv.env['GMAIL_PASSWORD'];

      // Validar que las credenciales estén configuradas
      if (gmailEmail == null || gmailEmail.isEmpty || 
          gmailPassword == null || gmailPassword.isEmpty) {
        print('❌ [EMAIL] Credenciales de Gmail no configuradas en .env');
        return false;
      }

      // Validar email
      if (!email.contains('@')) {
        print('❌ [EMAIL] Email inválido: $email');
        return false;
      }

      final smtpServer = gmail(gmailEmail, gmailPassword);

      final message = mailer.Message()
        ..from = mailer.Address(gmailEmail, 'IntelliHome - Recuperación')
        ..recipients.add(email)
        ..subject = 'Código de Recuperación de Contraseña - IntelliHome'
        ..html = _construirHtmlEmail(nombreUsuario, codigo);

      await mailer.send(message, smtpServer);
      print('✅ [EMAIL] Código enviado exitosamente a $email');
      return true;
    } catch (e) {
      print('❌ [EMAIL] Error al enviar email: $e');
      return false;
    }
  }

  /// Construye el HTML del email con el código
  static String _construirHtmlEmail(String nombreUsuario, String codigo) {
    return '''
      <html>
        <body style="font-family: Arial, sans-serif; background-color: #f5f5f5;">
          <div style="max-width: 600px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
            <h2 style="color: #1F5A74; text-align: center;">IntelliHome</h2>
            <p style="color: #333; font-size: 16px;">Hola <strong>$nombreUsuario</strong>,</p>
            <p style="color: #555; font-size: 14px;">Hemos recibido una solicitud para recuperar tu contraseña. Usa el siguiente código para continuar:</p>
            
            <div style="background-color: #1F5A74; color: white; padding: 20px; text-align: center; border-radius: 6px; margin: 20px 0;">
              <p style="font-size: 12px; margin: 0; opacity: 0.8;">CÓDIGO DE RECUPERACIÓN</p>
              <p style="font-size: 32px; font-weight: bold; margin: 10px 0; letter-spacing: 5px;">$codigo</p>
            </div>
            
            <p style="color: #999; font-size: 12px;">⏰ Este código expira en <strong>10 minutos</strong></p>
            <p style="color: #999; font-size: 12px;">🔒 Si no solicitaste esta recuperación, ignora este email.</p>
            
            <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
            <p style="color: #999; font-size: 11px; text-align: center;">© 2026 IntelliHome. Todos los derechos reservados.</p>
          </div>
        </body>
      </html>
    ''';
  }
}
