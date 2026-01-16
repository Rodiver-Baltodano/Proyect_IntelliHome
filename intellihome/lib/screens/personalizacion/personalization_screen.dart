import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:intellihome/providers/theme_provider.dart';
import 'package:intellihome/theme/theme_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PersonalizationScreen extends StatefulWidget {
  final String username;
  const PersonalizationScreen({super.key, required this.username});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  Color _tempColor = AppColors.primaryColor;
  bool _isPrimarySelected = true;
  bool _isBackgroundSelected = false;

  String _tema = 'medio';
  String _estilo = 'aventurero';
  bool _cargando = true;

  late UsuarioRepositorioJson _repo;
  ThemeProvider? _themeProvider;

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

      if (u != null) {
        final provider = ThemeProvider();
        provider.setRepositorio(_repo);
        provider.inicializarConUsuario(u);
        provider.addListener(() => mounted ? setState(() {}) : null);
        setState(() {
          _themeProvider = provider;
          _tema = u.tema;
          _estilo = u.estilo;
        });
      }
    } catch (e) {
      // no-op, UI-only fallback
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
              'Se ha registrado con éxito ${widget.username}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // 1) Personalizar colores
            _Section(
              title: 'Personalizar colores',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rueda de selección de color (solo UI, no guarda)
                  Center(
                    child: ColorPicker(
                      pickerColor: _tempColor,
                      onColorChanged: (c) => setState(() => _tempColor = c),
                      pickerAreaHeightPercent: 0.7,
                      enableAlpha: false,
                      labelTypes: const [],
                      displayThumbColor: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          value: _isPrimarySelected,
                          onChanged: (v) => setState(() => _isPrimarySelected = v ?? false),
                          title: const Text('Color primario'),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CheckboxListTile(
                          value: _isBackgroundSelected,
                          onChanged: (v) => setState(() => _isBackgroundSelected = v ?? false),
                          title: const Text('Color de fondo'),
                          controlAffinity: ListTileControlAffinity.leading,
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
              title: 'Tema',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Claro'),
                    selected: _themeProvider?.currentThemeType == ThemeType.claro || _tema == 'claro',
                    onSelected: (_) async {
                      setState(() => _tema = 'claro');
                      await _themeProvider?.changeTheme(ThemeType.claro);
                      _showSaved('Tema: Claro');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Medio'),
                    selected: _themeProvider?.currentThemeType == ThemeType.medio || _tema == 'medio',
                    onSelected: (_) async {
                      setState(() => _tema = 'medio');
                      await _themeProvider?.changeTheme(ThemeType.medio);
                      _showSaved('Tema: Medio');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Oscuro'),
                    selected: _themeProvider?.currentThemeType == ThemeType.oscuro || _tema == 'oscuro',
                    onSelected: (_) async {
                      setState(() => _tema = 'oscuro');
                      await _themeProvider?.changeTheme(ThemeType.oscuro);
                      _showSaved('Tema: Oscuro');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3) Estilo
            _Section(
              title: 'Estilo',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Minimalista ✨'),
                    selected: (_themeProvider?.currentStyle == StyleType.minimalista) || _estilo == 'minimalista',
                    onSelected: (_) async {
                      setState(() => _estilo = 'minimalista');
                      await _themeProvider?.changeStyle(StyleType.minimalista);
                      _showSaved('Estilo: Minimalista');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Aventurero 🚀'),
                    selected: (_themeProvider?.currentStyle == StyleType.aventurero) || _estilo == 'aventurero',
                    onSelected: (_) async {
                      setState(() => _estilo = 'aventurero');
                      await _themeProvider?.changeStyle(StyleType.aventurero);
                      _showSaved('Estilo: Aventurero');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Contemporáneo 🖼️'),
                    selected: (_themeProvider?.currentStyle == StyleType.contemporaneo) || _estilo == 'contemporaneo',
                    onSelected: (_) async {
                      setState(() => _estilo = 'contemporaneo');
                      await _themeProvider?.changeStyle(StyleType.contemporaneo);
                      _showSaved('Estilo: Contemporáneo');
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
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Listo'),
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
