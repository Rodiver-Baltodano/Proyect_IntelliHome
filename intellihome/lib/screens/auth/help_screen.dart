import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda'),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección: Acerca de la App
            Text(
              'Acerca de IntelliHome',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.secondaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IntelliHome es una aplicación de gestión de hogar inteligente que te permite controlar y monitorear todos tus dispositivos conectados desde un solo lugar.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimaryColor,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Versión: 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sección: Equipo Desarrollador
            Text(
              'Equipo Desarrollador',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
            ),
            const SizedBox(height: 12),
            _buildDeveloperCard(
              context,
              nombre: 'Rodiver Baltodano',
              rol: 'Desarrollador',
              email: 'r.baltodano.1@estudiantec.cr',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            _buildDeveloperCard(
              context,
              nombre: 'Christian Esquivel',
              rol: 'Desarrollador',
              email: 'c.esquivel.1@estudiantec.cr',
              icon: Icons.design_services,
            ),
            const SizedBox(height: 12),
            _buildDeveloperCard(
              context,
              nombre: 'Jose Solano',
              rol: 'Desarrollador',
              email: 'josesol_mo@estudiantec.cr',
              icon: Icons.design_services,
            ),
            const SizedBox(height: 12),
            _buildDeveloperCard(
              context,
              nombre: 'Isaac García',
              rol: 'Desarrollador',
              email: 'i.garcia.3@estudiantec.cr',
              icon: Icons.code,
            ),
            const SizedBox(height: 24),

            // Sección: Contacto
            Text(
              'Contacto y Soporte',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.secondaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContactItem(
                    context,
                    icon: Icons.email,
                    title: 'Correo electrónico',
                    info: 'soporte@intellihome.com',
                  ),
                  const Divider(height: 24),
                  _buildContactItem(
                    context,
                    icon: Icons.phone,
                    title: 'Teléfono',
                    info: '+506 0000-0000',
                  ),
                  const Divider(height: 24),
                  _buildContactItem(
                    context,
                    icon: Icons.language,
                    title: 'Sitio web',
                    info: 'www.intellihome.com',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sección: Características
            Text(
              'Características Principales',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.secondaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureItem(context, '• Control de dispositivos IoT'),
                  _buildFeatureItem(context, '• Monitoreo en tiempo real'),
                  _buildFeatureItem(context, '• Automatización de tareas'),
                  _buildFeatureItem(context, '• Gestión de energía'),
                  _buildFeatureItem(context, '• Seguridad y privacidad'),
                  _buildFeatureItem(context, '• Interfaz intuitiva'),
                   _buildFeatureItem(context,'• Gestión apartamentaria'),
                  _buildFeatureItem(context, '• Servicios de busqueda'),
                  _buildFeatureItem(context, '• Experiencia personalizada'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botón de cerrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(
    BuildContext context, {
    required String nombre,
    required String rol,
    required String email,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.secondaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            child: Icon(
              icon,
              color: AppColors.primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  rol,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryColor,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.accentColor,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String info,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                info,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimaryColor,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        feature,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimaryColor,
              height: 1.5,
            ),
      ),
    );
  }
}