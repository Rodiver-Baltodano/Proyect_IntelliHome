import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/l10n/app_localizations.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.help),
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
              loc.aboutApp,
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
                    loc.aboutApp,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimaryColor,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.version,
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
              loc.developerTeam,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
            ),
            const SizedBox(height: 12),
            _buildDeveloperCard(
              context,
              nombre: 'Rodiver Baltodano',
              rol: loc.developer,
              email: 'r.baltodano.1@estudiantec.cr',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            _buildDeveloperCard(
              context,
              nombre: 'Christian Esquivel',
              rol: loc.developer,
              email: 'c.esquivel.1@estudiantec.cr',
              icon: Icons.design_services,
            ),
            const SizedBox(height: 12),
            _buildDeveloperCard(
              context,
              nombre: 'Jose Solano',
              rol: loc.developer,
              email: 'josesol_mo@estudiantec.cr',
              icon: Icons.design_services,
            ),
            const SizedBox(height: 12),
            _buildDeveloperCard(
              context,
              nombre: 'Isaac García',
              rol: loc.developer,
              email: 'i.garcia.3@estudiantec.cr',
              icon: Icons.code,
            ),
            const SizedBox(height: 24),

            // Sección: Contacto
            Text(
              loc.contactSupport,
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
                    title: loc.emailLabel,
                    info: 'soporte@intellihome.com',
                  ),
                  const Divider(height: 24),
                  _buildContactItem(
                    context,
                    icon: Icons.phone,
                    title: loc.phoneLabel,
                    info: '+506 0000-0000',
                  ),
                  const Divider(height: 24),
                  _buildContactItem(
                    context,
                    icon: Icons.language,
                    title: loc.websiteLabel,
                    info: 'www.intellihome.com',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sección: Características
            Text(
              loc.mainFeatures,
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
                  _buildFeatureItem(context, '• ${loc.feature1}'),
                  _buildFeatureItem(context, '• ${loc.feature2}'),
                  _buildFeatureItem(context, '• ${loc.feature3}'),
                  _buildFeatureItem(context, '• ${loc.feature4}'),
                  _buildFeatureItem(context, '• ${loc.feature5}'),
                  _buildFeatureItem(context, '• ${loc.feature6}'),
                  _buildFeatureItem(context, '• ${loc.feature7}'),
                  _buildFeatureItem(context, '• ${loc.feature8}'),
                  _buildFeatureItem(context, '• ${loc.feature9}'),
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
                child: Text(loc.close),
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