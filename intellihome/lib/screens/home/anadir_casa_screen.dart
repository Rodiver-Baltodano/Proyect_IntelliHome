import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intellihome/config/app_colors.dart';

class AnadirCasaScreen extends StatefulWidget {
  const AnadirCasaScreen({super.key});

  @override
  State<AnadirCasaScreen> createState() => _AnadirCasaScreenState();
}

class _AnadirCasaScreenState extends State<AnadirCasaScreen> {
  int _maxPersonas = 1;
  int _cuartos = 1;

  late final TextEditingController _personasController;
  late final TextEditingController _cuartosController;

  @override
  void initState() {
    super.initState();
    _personasController = TextEditingController(text: _maxPersonas.toString());
    _cuartosController = TextEditingController(text: _cuartos.toString());
  }

  @override
  void dispose() {
    _personasController.dispose();
    _cuartosController.dispose();
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
                      Container(
                        height: fotoBoxHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primaryColor, width: 1.5),
                        ),
                        child: Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: const Text('Subir imágenes'),
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            ),
                          ),
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
            const _DetalleItem(
              icon: Icons.public,
              label: 'Ubicación',
            ),
            const SizedBox(height: 12),
            const _DetalleItem(
              icon: Icons.schedule,
              label: 'Reglas de uso',
            ),
            const SizedBox(height: 12),
            const _DetalleItem(
              icon: Icons.list_alt,
              label: 'Amenidades',
            ),
            const SizedBox(height: 12),
            const _DetalleItem(
              icon: Icons.calendar_today,
              label: 'Fechas',
            ),
          ],
        ),
      ),
    );
  }
}

class _DetalleItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetalleItem({required this.icon, required this.label});

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
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Añadir'),
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
