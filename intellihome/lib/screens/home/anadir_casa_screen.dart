import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';

class AnadirCasaScreen extends StatelessWidget {
  const AnadirCasaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir casa'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_home_outlined, size: 72, color: AppColors.primaryColor),
            const SizedBox(height: 16),
            const Text(
              'Pantalla de añadir casa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aquí podrás registrar una nueva propiedad.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
