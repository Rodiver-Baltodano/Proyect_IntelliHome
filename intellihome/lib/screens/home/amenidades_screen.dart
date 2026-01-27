import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/screens/home/amenidades_data.dart';

class AmenidadesScreen extends StatefulWidget {
  final Set<int> initialSelected;

  const AmenidadesScreen({super.key, required this.initialSelected});

  @override
  State<AmenidadesScreen> createState() => _AmenidadesScreenState();
}

class _AmenidadesScreenState extends State<AmenidadesScreen> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<int>.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amenidades'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: amenidadesCatalogo.length,
        separatorBuilder: (_, __) => const Divider(height: 12),
        itemBuilder: (context, index) {
          final item = amenidadesCatalogo[index];
          final checked = _selected.contains(item.id);
          return Row(
            children: [
              Icon(item.icono, color: AppColors.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.nombre,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Checkbox(
                value: checked,
                activeColor: AppColors.primaryColor,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selected.add(item.id);
                    } else {
                      _selected.remove(item.id);
                    }
                  });
                },
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _selected);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Aceptar'),
        ),
      ),
    );
  }
}
