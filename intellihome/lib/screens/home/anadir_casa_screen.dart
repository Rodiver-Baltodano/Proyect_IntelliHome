import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/screens/home/amenidades_data.dart';
import 'package:intellihome/screens/home/amenidades_screen.dart';
import 'package:intellihome/screens/home/fechas_no_disponibles_screen.dart';
import 'package:intellihome/screens/home/map_picker_screen.dart';
import 'package:latlong2/latlong.dart';

class AnadirCasaScreen extends StatefulWidget {
  const AnadirCasaScreen({super.key});

  @override
  State<AnadirCasaScreen> createState() => _AnadirCasaScreenState();
}

class _AnadirCasaScreenState extends State<AnadirCasaScreen> {
  int _maxPersonas = 1;
  int _cuartos = 1;

  final ImagePicker _imagePicker = ImagePicker();
  final List<File> _selectedImages = [];
  LatLng? _selectedLocation;
  Set<int> _selectedAmenidades = {};
  Set<DateTime> _blockedDates = {};

  bool _mostrarReglas = false;
  late final TextEditingController _reglasController;
  late final FocusNode _reglasFocusNode;

  late final TextEditingController _personasController;
  late final TextEditingController _cuartosController;

  @override
  void initState() {
    super.initState();
    _personasController = TextEditingController(text: _maxPersonas.toString());
    _cuartosController = TextEditingController(text: _cuartos.toString());
    _reglasController = TextEditingController();
    _reglasFocusNode = FocusNode();
    _reglasFocusNode.addListener(() {
      if (!_reglasFocusNode.hasFocus) {
        final tieneTexto = _reglasController.text.trim().isNotEmpty;
        setState(() {
          _mostrarReglas = tieneTexto;
        });
      }
    });
  }

  @override
  void dispose() {
    _personasController.dispose();
    _cuartosController.dispose();
    _reglasController.dispose();
    _reglasFocusNode.dispose();
    super.dispose();
  }

  void _incrementPersonas() {
    setState(() {
      _maxPersonas++;
      _personasController.text = _maxPersonas.toString();
    });
  }

  void _decrementPersonas() {
    if (_maxPersonas <= 1) return;
    setState(() {
      _maxPersonas--;
      _personasController.text = _maxPersonas.toString();
    });
  }

  void _incrementCuartos() {
    setState(() {
      _cuartos++;
      _cuartosController.text = _cuartos.toString();
    });
  }

  void _decrementCuartos() {
    if (_cuartos <= 1) return;
    setState(() {
      _cuartos--;
      _cuartosController.text = _cuartos.toString();
    });
  }

  Future<void> _pickImages() async {
    final picked = await _imagePicker.pickMultiImage();
    if (picked.isEmpty) return;

    if (picked.length > 10) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo 10 imágenes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _selectedImages.clear();
      for (final image in picked) {
        _selectedImages.add(File(image.path));
      }
    });
  }

  void _onReglasPressed() {
    setState(() {
      _mostrarReglas = true;
    });
    _reglasFocusNode.requestFocus();
  }

  Future<void> _pickBlockedDates() async {
    final result = await Navigator.push<Set<DateTime>>(
      context,
      MaterialPageRoute(
        builder: (_) => FechasNoDisponiblesScreen(
          initialSelected: _blockedDates,
        ),
      ),
    );

    if (result == null) return;
    setState(() {
      _blockedDates
        ..clear()
        ..addAll(
          result.map((d) => DateTime(d.year, d.month, d.day)),
        );
    });
  }

  Future<void> _pickAmenidades() async {
    final result = await Navigator.push<Set<int>>(
      context,
      MaterialPageRoute(
        builder: (_) => AmenidadesScreen(initialSelected: _selectedAmenidades),
      ),
    );

    if (result == null) return;
    setState(() {
      _selectedAmenidades = result;
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(initialLocation: _selectedLocation),
      ),
    );

    if (result == null) return;
    setState(() {
      _selectedLocation = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fotoBoxHeight = size.height * 0.4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir casa'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primera sección: Fotos (60%) + Detalles básicos (40%)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna 1: Fotos (60%)
                Expanded(
                  flex: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Se permiten un máximo de 10 fotos por casa y un minimo de 1',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: fotoBoxHeight,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Container(
                              height: fotoBoxHeight,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primaryColor, width: 1.5),
                                image: _selectedImages.isEmpty
                                    ? null
                                    : DecorationImage(
                                        image: FileImage(_selectedImages.first),
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(0.35),
                                          BlendMode.darken,
                                        ),
                                      ),
                              ),
                              child: Center(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.cloud_upload_outlined),
                                  label: const Text('Subir imágenes'),
                                  onPressed: _pickImages,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  ),
                                ),
                              ),
                            ),
                            if (_selectedImages.length > 1)
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 8,
                                child: SizedBox(
                                  height: 56,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _selectedImages.length - 1,
                                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      final image = _selectedImages[index + 1];
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.8),
                                              width: 1,
                                            ),
                                          ),
                                          child: Image.file(
                                            image,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Columna 2: Detalles básicos (40%) con ancho acotado para evitar campos muy amplios
                Expanded(
                  flex: 40,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // 1. Nombre de la casa
                      TextField(
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.05),
                        minLines: 4,
                        maxLines: 4,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Nombre su casa...',
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                            height: 1.05,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: fotoBoxHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 2. Precio por noche
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Precio por noche',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 0),
                                Row(
                                  children: [
                                    const Text('🇨🇷', style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: TextField(
                                        style: const TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          prefixText: '₵ ',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          ThousandsSeparatorInputFormatter(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // 3. Máximo de personas
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Máximo de personas permitidas',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 0),
                                Row(
                                  children: [
                                    const Icon(Icons.people, size: 16),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: TextField(
                                        controller: _personasController,
                                        readOnly: true,
                                        showCursor: false,
                                        enableInteractiveSelection: false,
                                        focusNode: FocusNode(canRequestFocus: false),
                                        style: const TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.primaryColor),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.arrow_drop_up, size: 14),
                                            onPressed: _incrementPersonas,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.arrow_drop_down, size: 14),
                                            onPressed: _maxPersonas <= 1 ? null : _decrementPersonas,
                                            color: _maxPersonas <= 1 ? Colors.grey : null,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // 4. Cuartos disponibles
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cuartos disponibles',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 0),
                                Row(
                                  children: [
                                    const Icon(Icons.meeting_room, size: 16),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: TextField(
                                        controller: _cuartosController,
                                        readOnly: true,
                                        showCursor: false,
                                        enableInteractiveSelection: false,
                                        focusNode: FocusNode(canRequestFocus: false),
                                        style: const TextStyle(fontSize: 13),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.primaryColor),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.arrow_drop_up, size: 14),
                                            onPressed: _incrementCuartos,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.arrow_drop_down, size: 14),
                                            onPressed: _cuartos <= 1 ? null : _decrementCuartos,
                                            color: _cuartos <= 1 ? Colors.grey : null,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Sección independiente: Descripción y Características
            const Text(
              'Descripción y Características',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              maxLines: 4,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Describa las características de la casa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Añadir casa'),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Detalles del lugar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _DetalleItem(
              icon: Icons.public,
              label: 'Ubicación',
              buttonLabel: _selectedLocation == null ? 'Añadir' : 'Editar',
              buttonIcon: _selectedLocation == null ? Icons.add : Icons.edit,
              onPressed: _pickLocation,
            ),
            const SizedBox(height: 12),
            _DetalleItem(
              icon: Icons.schedule,
              label: 'Reglas de uso',
              buttonLabel:
                  _reglasController.text.trim().isEmpty ? 'Añadir' : 'Editar',
              buttonIcon:
                  _reglasController.text.trim().isEmpty ? Icons.add : Icons.edit,
              onPressed: _onReglasPressed,
            ),
            if (_mostrarReglas || _reglasController.text.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _reglasController,
                focusNode: _reglasFocusNode,
                maxLines: 3,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Escriba las reglas de uso...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _DetalleItem(
              icon: Icons.list_alt,
              label: 'Amenidades',
              buttonLabel: _selectedAmenidades.isEmpty ? 'Añadir' : 'Editar',
              buttonIcon: _selectedAmenidades.isEmpty ? Icons.add : Icons.edit,
              onPressed: _pickAmenidades,
            ),
            if (_selectedAmenidades.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: amenidadesCatalogo
                      .where((item) => _selectedAmenidades.contains(item.id))
                      .length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final selectedItems = amenidadesCatalogo
                        .where((item) => _selectedAmenidades.contains(item.id))
                        .toList();
                    final item = selectedItems[index];
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryColor),
                      ),
                      child: Icon(item.icono, size: 18, color: AppColors.primaryColor),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            _DetalleItem(
              icon: Icons.calendar_today,
              label: 'Disponibilidad',
              buttonLabel: _blockedDates.isEmpty ? 'Añadir' : 'Editar',
              buttonIcon: _blockedDates.isEmpty ? Icons.add : Icons.edit,
              onPressed: _pickBlockedDates,
            ),
            if (_blockedDates.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: (() {
                  final dates = _blockedDates.toList()
                    ..sort((a, b) => a.compareTo(b));
                  return dates
                      .map(
                        (date) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryColor),
                          ),
                          child: Text(
                            _formatDate(date),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList();
                })(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetalleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback? onPressed;

  const _DetalleItem({
    required this.icon,
    required this.label,
    this.buttonLabel = 'Añadir',
    this.buttonIcon = Icons.add,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 140,
          child: OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(buttonIcon),
            label: Text(buttonLabel),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              side: BorderSide(color: AppColors.primaryColor),
              foregroundColor: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      final indexFromRight = digitsOnly.length - i;
      buffer.write(digitsOnly[i]);
      if (indexFromRight > 1 && indexFromRight % 3 == 1) {
        buffer.write(',');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
