import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/l10n/app_localizations.dart';

class DomoticScreen extends StatefulWidget {
  const DomoticScreen({super.key});

  @override
  State<DomoticScreen> createState() => _DomoticScreenState();
}

class _DomoticScreenState extends State<DomoticScreen> {
  // Estados de las luces por habitación
  Map<String, bool> lightStates = {
    'garaje': false,
    'sala': false,
    'cocina': false,
    'bano1': false,
    'bano2': false,
    'cuarto1': false,
    'cuarto2': false,
    'cuarto3': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Domótico'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Imagen del plano de la casa
                  Positioned.fill(
                    child: Image.asset(
                      'lib/assets/icons/house_plan.png', 
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  // Garaje - Izquierda inferior
                  _buildLightButton(
                    'garaje',
                    'Garaje',
                    left: constraints.maxWidth * 0.50,
                    top: constraints.maxHeight * 0.68,
                  ),
                  
                  // Sala - Centro inferior
                  _buildLightButton(
                    'sala',
                    'Sala',
                    left: constraints.maxWidth * 0.50,
                    top: constraints.maxHeight * 0.49,
                  ),
                  
                  // Cocina - Izquierda superior
                  _buildLightButton(
                    'cocina',
                    'Cocina',
                    left: constraints.maxWidth * 0.16,
                    top: constraints.maxHeight * 0.49,
                  ),
                  
                  // Baño 1 - Centro superior
                  _buildLightButton(
                    'bano1',
                    'Baño 1',
                    left: constraints.maxWidth * 0.16,
                    top: constraints.maxHeight * 0.32,
                  ),
                  
                  // Baño 2 - Centro medio
                  _buildLightButton(
                    'bano2',
                    'Baño 2',
                    left: constraints.maxWidth * 0.60,
                    top: constraints.maxHeight * 0.32,
                  ),
                  
                  // Cuarto 1 - Superior derecha
                  _buildLightButton(
                    'cuarto1',
                    'Cuarto 1',
                    left: constraints.maxWidth * 0.15,
                    top: constraints.maxHeight * 0.18,
                  ),
                  
                  // Cuarto 2 - Derecha medio
                  _buildLightButton(
                    'cuarto2',
                    'Cuarto 2',
                    left: constraints.maxWidth * 0.35,
                    top: constraints.maxHeight * 0.18,
                  ),
                  
                  // Cuarto 3 - Derecha inferior
                  _buildLightButton(
                    'cuarto3',
                    'Cuarto 3',
                    left: constraints.maxWidth * 0.60,
                    top: constraints.maxHeight * 0.18,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLightButton(
    String roomKey,
    String roomName, {
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    final isOn = lightStates[roomKey] ?? false;
    
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: isOn
                  ? [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
            ),
            child: IconButton(
              icon: Icon(
                isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                size: 28,
              ),
              color: isOn ? Colors.amber.shade600 : Colors.grey.shade600,
              onPressed: () {
                setState(() {
                  lightStates[roomKey] = !isOn;
                });
                // Aquí irá la lógica de control domótico más adelante
              },
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              roomName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}