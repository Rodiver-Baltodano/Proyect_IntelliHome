import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/l10n/app_localizations.dart';

class TermsUI extends StatefulWidget {
  const TermsUI({super.key});

  @override
  State<TermsUI> createState() => _TermsUIState();
}

class _TermsUIState extends State<TermsUI> {
  bool _accepted = false;
  final ScrollController _scrollController = ScrollController();
  bool _atBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final bool isAtBottom = position.pixels >= (position.maxScrollExtent - 16);
    if (isAtBottom != _atBottom) {
      setState(() {
        _atBottom = isAtBottom;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).termsTitle),
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
              AppLocalizations.of(context).termsTitle,
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
                  controller: _scrollController,
                  child: Text(
                    AppLocalizations.of(context).termsContent,
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
                    onChanged: _atBottom
                        ? (value) {
                            setState(() {
                              _accepted = value ?? false;
                            });
                          }
                        : null,
                  ),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).acceptTermsCheckbox,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (!_atBottom && !_accepted) ...[
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).scrollToEndToAccept,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 20),

            // Botón de aceptar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: (_accepted && _atBottom)
                    ? AppColors.primaryColor
                    : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: (_accepted && _atBottom)
                  ? () {
                      Navigator.pop(context, true);
                    }
                  : null,
              child: Text(
                AppLocalizations.of(context).acceptAndContinue,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              child: Text(
                AppLocalizations.of(context).cancel,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
