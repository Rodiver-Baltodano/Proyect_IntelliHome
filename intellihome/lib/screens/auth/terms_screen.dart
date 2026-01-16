import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';

class TermsUI extends StatefulWidget {
  const TermsUI({super.key});

  @override
  State<TermsUI> createState() => _TermsUIState();
}

class _TermsUIState extends State<TermsUI> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Encabezado
            Text(
              'Términos y Condiciones de IntelliHome',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Contenido de términos
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.secondaryColor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Text(
                    '''
                    Términos y Condiciones de Uso de Intelihome 
Última actualización: 8/1/2025 
Bienvenido a Intelihome. Estos Términos y Condiciones ("Términos") regulan el acceso y uso de 
nuestra plataforma, servicios y aplicaciones (colectivamente, "la Plataforma"). Al acceder o utilizar 
Intelihome, usted acepta estar sujeto a estos Términos. 

1. Definiciones 
• "Intelihome": se refiere a la plataforma y los servicios ofrecidos para conectar a anfitriones 
y huéspedes. 
• "Usuario": cualquier persona que accede a la Plataforma, ya sea como anfitrión o 
huésped. 
• "Anfitrión": usuario que publica propiedades para ser reservadas. 
• "Huésped": usuario que realiza reservas a través de la Plataforma. 
• "Contenido": toda información, texto, imágenes, videos, y cualquier otro material 
compartido en la Plataforma. 

2. Aceptación de los Términos Al usar Intelihome, usted declara que tiene al menos 12 años de 
edad y que tiene la capacidad legal para aceptar estos Términos. Si no está de acuerdo con alguno 
de los Términos, debe abstenerse de utilizar la Plataforma.

3. Registro y Cuentas 
• Para usar Intelihome, debe crear una cuenta proporcionando información veraz y 
completa. 
• Usted es responsable de mantener la confidencialidad de su cuenta y contraseña. 
• Intelihome se reserva el derecho de suspender o cancelar cuentas en caso de uso indebido 
o violación de estos Términos. 

4. Uso de la Plataforma 
• Los anfitriones deben garantizar que las propiedades publicadas cumplen con las leyes 
locales y están debidamente habilitadas para ser alquiladas. 
• Los huéspedes son responsables de usar las propiedades de manera respetuosa y de 
cumplir con las reglas establecidas por los anfitriones. 
• Está prohibido publicar contenido que sea ofensivo, ilegal o que viole derechos de 
terceros. 

5. Tarifas y Pagos 
• Intelihome cobra tarifas por el uso de la Plataforma, las cuales se detallan durante el 
proceso de reserva. 
• Los pagos se procesan a través de sistemas seguros de terceros. Intelihome no almacena 
información de tarjetas de crédito. 
• Cualquier reembolso está sujeto a las políticas especificadas en el momento de la reserva.

6. Políticas de Cancelación 
• Los anfitriones pueden establecer sus propias políticas de cancelación, siempre que se 
ajusten a las directrices de Intelihome. 
• Las cancelaciones realizadas por los huéspedes estarán sujetas a dichas políticas. 
• Intelihome se reserva el derecho de intervenir en disputas relacionadas con cancelaciones. 

7. Limitación de Responsabilidad 
• Intelihome no garantiza la calidad, seguridad o legalidad de las propiedades anunciadas. 
• Intelihome no será responsable por daños directos, indirectos o incidentales derivados del 
uso de la Plataforma. 
• Los usuarios asumen toda responsabilidad por las interacciones y acuerdos realizados a 
través de Intelihome. 

8. Propiedad Intelectual 
• Todo el contenido de la Plataforma, incluyendo logos, marcas y diseños, es propiedad de 
Intelihome o sus licenciantes. 
• Está prohibido reproducir, distribuir o usar dicho contenido sin autorización previa. 

9. Modificaciones a los Términos Intelihome se reserva el derecho de modificar estos Términos en 
cualquier momento. Las modificaciones serán notificadas a los usuarios a través de la Plataforma. 
El uso continuado de Intelihome implica la aceptación de los Términos actualizados. 

10. Ley Aplicable y Jurisdicción Estos Términos se regirán por las leyes del país donde Intelihome 
tenga su sede principal. Cualquier disputa será resuelta ante los tribunales competentes de dicha 
jurisdicción. 

11. Contacto Si tiene preguntas sobre estos Términos, puede contactarnos en: 
Correo electrónico: soporte@intelihome.com  


Gracias por elegir Intelihome. Disfrute de su experiencia en nuestra plataforma.
                    ''',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimaryColor,
                          height: 1.5,
                        ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Checkbox de aceptación
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _accepted
                      ? AppColors.primaryColor
                      : AppColors.secondaryColor.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Checkbox(
                    value: _accepted,
                    activeColor: AppColors.primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _accepted = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'He leído y acepto los términos y condiciones',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Botón de aceptar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _accepted ? AppColors.primaryColor : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _accepted
                  ? () {
                      Navigator.pop(context, true);
                    }
                  : null,
              child: const Text(
                'Aceptar y Continuar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Botón de cancelar
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.tertiaryColor,
                side: BorderSide(color: AppColors.tertiaryColor, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}