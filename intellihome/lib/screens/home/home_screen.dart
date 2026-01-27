import 'package:flutter/material.dart';
import 'dart:io';

import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/l10n/app_localizations.dart';
import 'package:intellihome/modules/autenticacion/models/casa.dart';
import 'package:intellihome/modules/autenticacion/repositories/casa_repositorio_json.dart';
import 'package:intellihome/modules/reservas/services/reserva_sync_service.dart';
import 'package:intellihome/providers/theme_provider.dart';
import 'package:intellihome/screens/home/domotic_screen.dart';
import 'package:intellihome/screens/home/historial_reservas_screen.dart';
import 'package:intellihome/screens/home/mis_casas_screen.dart';
import 'package:intellihome/screens/home/reservar_casa_screen.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({
    super.key,
    required this.username,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, int> _imageIndexByCasa = {};

  @override
  void initState() {
    super.initState();
    _activarReservasPendientes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Casa>> _cargarCasas() async {
    final appDir = await getApplicationDocumentsDirectory();
    final rutaJson = p.join(appDir.path, 'casas_integrado.json');
    final repo = CasaRepositorioJson(rutaArchivo: rutaJson);
    return repo.cargarCasas();
  }

  Future<void> _activarReservasPendientes() async {
    await ReservaSyncService().activarReservasPendientesHoy();
  }

  void _toggleImage(Casa casa) {
    final total = casa.fotos.length;
    if (total <= 1) return;
    final current = _imageIndexByCasa[casa.id] ?? 0;
    final next = (current + 1) % total;
    setState(() {
      _imageIndexByCasa[casa.id] = next;
    });
  }

  ImageProvider? _buildCasaImage(String? ruta) {
    if (ruta == null || ruta.isEmpty) return null;
    if (ruta.startsWith('http')) {
      return NetworkImage(ruta);
    }
    final file = File(ruta);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }

  ImageProvider? _buildImageProvider(String? ruta) {
    if (ruta == null || ruta.isEmpty) return null;
    if (ruta.startsWith('http')) {
      return NetworkImage(ruta);
    }
    final file = File(ruta);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }

  String _formatPrecio(double precio) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(precio);
  }

  String _normalizeText(String value) {
    final lower = value.toLowerCase().trim();
    const accents = 'áéíóúüñ';
    const replacements = 'aeiouun';
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      final idx = accents.indexOf(char);
      buffer.write(idx >= 0 ? replacements[idx] : char);
    }
    return buffer.toString();
  }

  bool _matchesQuery(String titulo, String query) {
    final normalizedTitle = _normalizeText(titulo);
    final normalizedQuery = _normalizeText(query);

    if (normalizedQuery.isEmpty) return true;
    if (normalizedTitle.contains(normalizedQuery)) return true;

    final titleTokens = normalizedTitle.split(RegExp(r'\s+'));
    final queryTokens = normalizedQuery.split(RegExp(r'\s+'));

    final allTokensMatch = queryTokens.every(
      (token) => titleTokens.any((t) => t.startsWith(token)),
    );
    if (allTokensMatch) return true;

    return _levenshteinDistance(normalizedTitle, normalizedQuery) <= 2;
  }

  int _levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    final rows = List<int>.generate(t.length + 1, (i) => i);
    for (var i = 0; i < s.length; i++) {
      var prev = i + 1;
      for (var j = 0; j < t.length; j++) {
        final current = rows[j + 1];
        final cost = s[i] == t[j] ? 0 : 1;
        rows[j + 1] = [
          rows[j + 1] + 1,
          prev + 1,
          rows[j] + cost,
        ].reduce((a, b) => a < b ? a : b);
        prev = current;
      }
      rows[0] = i + 1;
    }
    return rows[t.length];
  }

  _EstiloDisplay? _estiloConEmoji(String estilo, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (estilo) {
      case 'aventurero':
        return _EstiloDisplay(label: l10n.adventurous, emoji: '🚀');
      case 'minimalista':
        return _EstiloDisplay(label: l10n.minimalist, emoji: '✨');
      case 'contemporaneo':
        return _EstiloDisplay(label: l10n.contemporary, emoji: '🖼️');
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final usuario = themeProvider.usuarioActual;
    final nombreUsuario = usuario?.username ?? widget.username;
    final fotoPerfil = usuario?.fotoPerfil;
    final estilo = usuario?.estilo ?? themeProvider.currentStyle.name;
    final estiloDisplay = _estiloConEmoji(estilo, context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IntelliHome'),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                border: const Border(
                  bottom: BorderSide(color: Colors.transparent, width: 0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IntelliHome',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        backgroundImage: _buildImageProvider(fotoPerfil),
                        child: (fotoPerfil == null || fotoPerfil.isEmpty)
                            ? const Icon(Icons.person, size: 40, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombreUsuario,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (estiloDisplay != null)
                              Text(
                                '${estiloDisplay.emoji} ${estiloDisplay.label}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Opción de Control Domótico

            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: Text(AppLocalizations.of(context).domoticControl),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DomoticScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home_work_outlined),
              title: const Text('Mis casas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MisCasasScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial de reservas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistorialReservasScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_home_outlined),
              title: const Text('Añadir casa'),
              onTap: () async {
                Navigator.pop(context);
                final resultado = await Navigator.pushNamed(
                  context,
                  '/anadir_casa',
                );
                if (!mounted) return;
                if (resultado == '¡Casa añadida!') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '¡Casa añadida!',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppColors.successColor,
                    ),
                  );
                  setState(() {});
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: Text(AppLocalizations.of(context).customize),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/personalizacion',
                  arguments: {
                    'username': widget.username,
                    'fromRegister': false,
                  },
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: Text(AppLocalizations.of(context).logout),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar casas...',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: BorderSide(color: AppColors.primaryColor),
                    ),
                    child: Icon(Icons.filter_list, color: AppColors.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Casa>>(
              future: _cargarCasas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error al cargar casas: ${snapshot.error}'),
                  );
                }
                final casas = snapshot.data ?? [];
                final query = _searchController.text.trim().toLowerCase();
                final filtradas = query.isEmpty
                    ? casas
                    : casas
                        .where((c) => _matchesQuery(c.nombre, query))
                        .toList();

                if (filtradas.isEmpty) {
                  return const Center(
                    child: Text('No hay casas publicadas.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filtradas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final casa = filtradas[index];
                    final imageIndex = _imageIndexByCasa[casa.id] ?? 0;
                    final imagePath = casa.fotos.isNotEmpty
                        ? casa.fotos[imageIndex.clamp(0, casa.fotos.length - 1)]
                        : null;
                    final imageProvider = _buildCasaImage(imagePath);

                    return InkWell(
                      onTap: () => _toggleImage(casa),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Stack(
                                children: [
                                  SizedBox(
                                    height: 180,
                                    width: double.infinity,
                                    child: imageProvider != null
                                        ? Image(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: AppColors.backgroundColor,
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: AppColors.textSecondaryColor,
                                              size: 40,
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                    left: 12,
                                    bottom: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.45),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            casa.nombre,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '₵ ${_formatPrecio(casa.precioPorNoche)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ReservarCasaScreen(
                                            casa: casa,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.remove_red_eye_outlined),
                                    color: AppColors.primaryColor,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Ver detalles',
                                    style: TextStyle(
                                      color: AppColors.textSecondaryColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EstiloDisplay {
  final String label;
  final String emoji;

  _EstiloDisplay({required this.label, required this.emoji});
}