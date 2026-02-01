import 'package:flutter/material.dart';
import 'dart:io';

import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/l10n/app_localizations.dart';
import 'package:intellihome/modules/autenticacion/models/casa.dart';
import 'package:intellihome/modules/autenticacion/repositories/casa_repositorio_json.dart';
import 'package:intellihome/modules/filters/services/filtro_casas_service.dart';
import 'package:intellihome/modules/reservas/services/reserva_sync_service.dart';
import 'package:intellihome/modules/ubicacion/services/ubicacion_service.dart';
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
  final ScrollController _listController = ScrollController();
  final Map<String, int> _imageIndexByCasa = {};
  final Map<String, Future<String>> _ubicacionFutures = {};
  late final Future<List<Casa>> _casasFuture;
  late Future<List<Casa>> _filteredFuture;
  bool _mostrarFiltros = false;
  bool _cercaDeMi = false;
  RangeValues _cuartosRango = const RangeValues(1, 8);
  RangeValues _personasRango = const RangeValues(1, 16);
  RangeValues _precioRango = const RangeValues(0, 100000);

  @override
  void initState() {
    super.initState();
    _activarReservasPendientes();
    _casasFuture = _cargarCasas();
    _filteredFuture = _buildFilteredFuture();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<List<Casa>> _cargarCasas() async {
    final appDir = await getApplicationDocumentsDirectory();
    final rutaJson = p.join(appDir.path, 'casas_integrado.json');
    final repo = CasaRepositorioJson(rutaArchivo: rutaJson);
    return repo.cargarCasas();
  }

  Future<List<Casa>> _buildFilteredFuture() async {
    final casas = await _casasFuture;
    final query = _searchController.text.trim().toLowerCase();
    final filtradas = query.isEmpty
        ? casas
        : casas.where((c) => _matchesQuery(c.nombre, query)).toList();
    return _aplicarFiltros(filtradas);
  }

  void _updateFilteredFuture() {
    _filteredFuture = _buildFilteredFuture();
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

  ({double lat, double lng})? _parseCoords(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return (lat: lat, lng: lng);
  }

  Future<String> _resolverUbicacion(Casa casa) async {
    final coords = _parseCoords(casa.ubicacion);
    if (coords == null) return 'Sin ubicación';
    return UbicacionService().obtenerProvinciaCanton(
      lat: coords.lat,
      lng: coords.lng,
    );
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

  Future<List<Casa>> _aplicarFiltros(List<Casa> casas) {
    return FiltroCasasService().filtrar(
      casas: casas,
      cercaDeMi: _cercaDeMi,
      precioMin: _precioRango.start,
      precioMax: _precioRango.end,
      cuartosMin: _cuartosRango.start,
      cuartosMax: _cuartosRango.end,
      personasMin: _personasRango.start,
      personasMax: _personasRango.end,
    );
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
                    onChanged: (_) {
                      setState(_updateFilteredFuture);
                    },
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
                    onPressed: () {
                      setState(() {
                        _mostrarFiltros = !_mostrarFiltros;
                      });
                    },
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
          if (_mostrarFiltros)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personaliza tu búsqueda',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Ubicación',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: _cercaDeMi,
                      onChanged: (value) {
                        setState(() {
                          _cercaDeMi = value ?? false;
                          _updateFilteredFuture();
                        });
                      },
                      title: const Text('Lugares cercanos a mi'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.bed_outlined,
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Cantidad de cuartos (${_cuartosRango.start.round()}-${_cuartosRango.end.round()})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: _cuartosRango,
                      min: 1,
                      max: 8,
                      divisions: 7,
                      labels: RangeLabels(
                        _cuartosRango.start.round().toString(),
                        _cuartosRango.end.round().toString(),
                      ),
                      onChanged: (values) {
                        setState(() {
                          _cuartosRango = values;
                          _updateFilteredFuture();
                        });
                      },
                    ),
                    Text(
                      '${_cuartosRango.start.round()} - ${_cuartosRango.end.round()} cuartos',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Cantidad de personas (${_personasRango.start.round()}-${_personasRango.end.round()})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: _personasRango,
                      min: 1,
                      max: 16,
                      divisions: 15,
                      labels: RangeLabels(
                        _personasRango.start.round().toString(),
                        _personasRango.end.round().toString(),
                      ),
                      onChanged: (values) {
                        setState(() {
                          _personasRango = values;
                          _updateFilteredFuture();
                        });
                      },
                    ),
                    Text(
                      '${_personasRango.start.round()} - ${_personasRango.end.round()} personas',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Precio por noche (₵${_formatPrecio(_precioRango.start)}-₵${_formatPrecio(_precioRango.end)})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: _precioRango,
                      min: 0,
                      max: 100000,
                      divisions: 20,
                      labels: RangeLabels(
                        '₵ ${_formatPrecio(_precioRango.start)}',
                        '₵ ${_formatPrecio(_precioRango.end)}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _precioRango = values;
                          _updateFilteredFuture();
                        });
                      },
                    ),
                    Text(
                      '₵ ${_formatPrecio(_precioRango.start)} - ₵ ${_formatPrecio(_precioRango.end)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Casa>>(
              future: _filteredFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error al cargar casas: ${snapshot.error}'),
                  );
                }
                final casasFiltradas = snapshot.data ?? [];
                if (casasFiltradas.isEmpty) {
                  return const Center(
                    child: Text('No hay casas publicadas.'),
                  );
                }

                return ListView.separated(
                  controller: _listController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: casasFiltradas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final casa = casasFiltradas[index];
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
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      layoutBuilder: (currentChild, previousChildren) {
                                        return Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ...previousChildren,
                                            ?currentChild,
                                          ],
                                        );
                                      },
                                      child: imageProvider != null
                                          ? Image(
                                              key: ValueKey(imagePath),
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                              gaplessPlayback: true,
                                            )
                                          : Container(
                                              key: const ValueKey('no-image'),
                                              color: AppColors.backgroundColor,
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: AppColors.textSecondaryColor,
                                                size: 40,
                                              ),
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
                                  Positioned(
                                    right: 12,
                                    top: 12,
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
                                          const Icon(
                                            Icons.meeting_room_outlined,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            casa.habitaciones.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(
                                            Icons.people_outline,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            casa.maxPersonas.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
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
                                  Row(
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
                                        icon: const Icon(
                                          Icons.remove_red_eye_outlined,
                                        ),
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
                                  const Spacer(),
                                  SizedBox(
                                    width: 150,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          child: Icon(
                                            Icons.place_outlined,
                                            size: 14,
                                            color: AppColors.textSecondaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: FutureBuilder<String>(
                                            future: _ubicacionFutures[casa.id] ??=
                                                _resolverUbicacion(casa),
                                            builder: (context, snapshot) {
                                              final texto = snapshot.data ??
                                                  (snapshot.connectionState ==
                                                          ConnectionState.waiting
                                                      ? 'Cargando...'
                                                      : 'Sin ubicación');
                                              return _MarqueeText(
                                                text: texto,
                                                style: TextStyle(
                                                  color: AppColors.textSecondaryColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
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

class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _MarqueeText({
    required this.text,
    required this.style,
  });

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText> {
  final ScrollController _controller = ScrollController();
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void didUpdateWidget(covariant _MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _start(reset: true);
    }
  }

  Future<void> _start({bool reset = false}) async {
    if (!mounted) return;
    if (_running) return;
    _running = true;

    if (reset && _controller.hasClients) {
      _controller.jumpTo(0);
    }

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted || !_controller.hasClients) {
      _running = false;
      return;
    }

    final maxScroll = _controller.position.maxScrollExtent;
    if (maxScroll <= 0) {
      _running = false;
      return;
    }

    while (mounted && _controller.hasClients) {
      if (!_controller.hasClients) break;
      final duration = Duration(milliseconds: (maxScroll * 20).toInt().clamp(800, 8000));
      try {
        await _controller.animateTo(
          maxScroll,
          duration: duration,
          curve: Curves.linear,
        );
      } catch (_) {
        break;
      }
      if (!mounted || !_controller.hasClients) break;
      await Future.delayed(const Duration(milliseconds: 800));
      if (!_controller.hasClients) break;
      _controller.jumpTo(0);
      await Future.delayed(const Duration(milliseconds: 800));
    }

    _running = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.style.fontSize != null ? widget.style.fontSize! + 4 : 18,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Text(
          widget.text,
          style: widget.style,
          maxLines: 1,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }
}