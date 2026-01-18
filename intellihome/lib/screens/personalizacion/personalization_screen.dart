import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:intellihome/theme/theme_colors.dart';
import 'package:intellihome/providers/theme_provider.dart';
import 'package:intellihome/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PersonalizationScreen extends StatefulWidget {
  final String username;
  final bool fromRegister;
  
  const PersonalizationScreen({
    super.key,
    required this.username,
    this.fromRegister = true,
  });

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  // Rastrear qué botón está activo: 'primary' o 'background'
  String _colorSeleccionado = 'primary';
  
  // Colores actuales mostrados en los botones (cambian con el tema)
  Color _colorPrimario = MedioThemeColors.primary;
  Color _colorFondo = MedioThemeColors.background;

  String _tema = 'medio';
  String _estilo = 'aventurero';
  bool _cargando = true;

  late UsuarioRepositorioJson _repo;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final rutaJson = p.join(appDir.path, 'usuarios_integrado.json');
      _repo = UsuarioRepositorioJson(rutaArchivo: rutaJson);

      final u = await _repo.buscarPorIdentificador(widget.username);

      if (u != null && mounted) {
        // Inicializar el provider global con el usuario
        final provider = context.read<ThemeProvider>();
        provider.setRepositorio(_repo);
        provider.inicializarConUsuario(u);
        
        setState(() {
          _tema = u.tema;
          _estilo = u.estilo;
          // Inicializar colores desde el provider
          _colorPrimario = provider.currentTheme.primary;
          _colorFondo = provider.currentTheme.background;
        });
      }
    } catch (e) {
      print('Error inicializando personalización: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IntelliHome'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_cargando) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 24),
            ],
            // Mensaje de éxito
            Text(
              '${AppLocalizations.of(context).registeredSuccessfully} ${widget.username}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // 1) Personalizar colores
            _Section(
              title: AppLocalizations.of(context).customizeColors,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rueda de selección de color
                  Center(
                    child: ColorPicker(
                      pickerColor: _colorSeleccionado == 'primary' ? _colorPrimario : _colorFondo,
                      onColorChanged: (c) {
                        setState(() {
                          if (_colorSeleccionado == 'primary') {
                            _colorPrimario = c;
                            // Actualizar en tiempo real sin persistir
                            context.read<ThemeProvider>().updatePrimaryColorPreview(c);
                          } else {
                            _colorFondo = c;
                            // Actualizar en tiempo real sin persistir
                            context.read<ThemeProvider>().updateBackgroundColorPreview(c);
                          }
                        });
                      },
                      pickerAreaHeightPercent: 0.7,
                      enableAlpha: false,
                      labelTypes: const [],
                      displayThumbColor: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botones para seleccionar qué color editar
                  Row(
                    children: [
                      Expanded(
                        child: _ColorButton(
                          label: AppLocalizations.of(context).primaryColor,
                          color: _colorPrimario,
                          isSelected: _colorSeleccionado == 'primary',
                          onTap: () => setState(() => _colorSeleccionado = 'primary'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ColorButton(
                          label: AppLocalizations.of(context).backgroundColor,
                          color: _colorFondo,
                          isSelected: _colorSeleccionado == 'background',
                          onTap: () => setState(() => _colorSeleccionado = 'background'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2) Tema
            _Section(
              title: AppLocalizations.of(context).theme,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(AppLocalizations.of(context).light),
                    selected: _tema == 'claro',
                    onSelected: (_) {
                      setState(() {
                        _tema = 'claro';
                        _colorPrimario = ClaroThemeColors.primary;
                        _colorFondo = ClaroThemeColors.background;
                      });
                      // Cambiar en tiempo real sin persistir
                      context.read<ThemeProvider>().changeThemePreview(ThemeType.claro);
                      _showSaved('${AppLocalizations.of(context).theme}: ${AppLocalizations.of(context).light}');
                    },
                  ),
                  ChoiceChip(
                    label: Text(AppLocalizations.of(context).medium),
                    selected: _tema == 'medio',
                    onSelected: (_) {
                      setState(() {
                        _tema = 'medio';
                        _colorPrimario = MedioThemeColors.primary;
                        _colorFondo = MedioThemeColors.background;
                      });
                      // Cambiar en tiempo real sin persistir
                      context.read<ThemeProvider>().changeThemePreview(ThemeType.medio);
                      _showSaved('${AppLocalizations.of(context).theme}: ${AppLocalizations.of(context).medium}');
                    },
                  ),
                  ChoiceChip(
                    label: Text(AppLocalizations.of(context).dark),
                    selected: _tema == 'oscuro',
                    onSelected: (_) {
                      setState(() {
                        _tema = 'oscuro';
                        _colorPrimario = OscuroThemeColors.primary;
                        _colorFondo = OscuroThemeColors.background;
                      });
                      // Cambiar en tiempo real sin persistir
                      context.read<ThemeProvider>().changeThemePreview(ThemeType.oscuro);
                      _showSaved('${AppLocalizations.of(context).theme}: ${AppLocalizations.of(context).dark}');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3) Estilo
            _Section(
              title: AppLocalizations.of(context).style,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(AppLocalizations.of(context).minimalistStyle),
                    selected: _estilo == 'minimalista',
                    onSelected: (_) {
                      setState(() => _estilo = 'minimalista');
                      context.read<ThemeProvider>().changeStylePreview(StyleType.minimalista);
                      _showSaved('${AppLocalizations.of(context).style}: ${AppLocalizations.of(context).minimalistStyle}');
                    },
                  ),
                  ChoiceChip(
                    label: Text(AppLocalizations.of(context).adventurousStyle),
                    selected: _estilo == 'aventurero',
                    onSelected: (_) {
                      setState(() => _estilo = 'aventurero');
                      context.read<ThemeProvider>().changeStylePreview(StyleType.aventurero);
                      _showSaved('${AppLocalizations.of(context).style}: ${AppLocalizations.of(context).adventurousStyle}');
                    },
                  ),
                  ChoiceChip(
                    label: Text(AppLocalizations.of(context).contemporaryStyle),
                    selected: _estilo == 'contemporaneo',
                    onSelected: (_) {
                      setState(() => _estilo = 'contemporaneo');
                      context.read<ThemeProvider>().changeStylePreview(StyleType.contemporaneo);
                      _showSaved('${AppLocalizations.of(context).style}: ${AppLocalizations.of(context).contemporaryStyle}');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Botón Listo
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                // Guardar todos los cambios en el usuario
                try {
                  await context.read<ThemeProvider>().guardarCambios(_tema, _estilo);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${AppLocalizations.of(context).personalizationSaved} ${widget.username}'),
                        backgroundColor: AppColors.successColor,
                      ),
                    );
                    // Si viene de registro, ir a login. Si viene de home, ir a home
                    if (widget.fromRegister) {
                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      Navigator.pushReplacementNamed(
                        context,
                        '/home',
                        arguments: widget.username,
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${AppLocalizations.of(context).errorSaving} $e'),
                        backgroundColor: AppColors.errorColor,
                      ),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context).done),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaved(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$msg guardado'),
        backgroundColor: AppColors.successColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// Widget para botón de selección de color con círculo visual
class _ColorButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Círculo mostrando el color
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[400]!, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Texto
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryColor : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: AppColors.secondaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
