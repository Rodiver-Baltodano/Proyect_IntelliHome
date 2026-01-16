import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _usernameController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _ibanController = TextEditingController();

  String _nacionalidadSeleccionada = 'Costa Rica';
  
  final List<String> _nacionalidades = [
    'Costa Rica',
    'El Salvador',
    'Guatemala',
    'Honduras',
    'Nicaragua',
    'Panamá',
    'Belice',
    'México',
    'Colombia',
    'España',
    'Argentina',
    'Chile',
    'Perú',
    'Otro',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _usernameController.dispose();
    _contrasenaController.dispose();
    _telefonoController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    print('=== Registro de Usuario ===');
    print('Nombre: ${_nombreController.text}');
    print('Correo Electrónico: ${_correoController.text}');
    print('Usuario: ${_usernameController.text}');
    print('Contraseña: ${_contrasenaController.text}');
    print('Teléfono: ${_telefonoController.text}');
    print('Nacionalidad: $_nacionalidadSeleccionada');
    print('IBAN: ${_ibanController.text}');
    print('==========================');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulario de registro completado'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IntelliHome'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              Text(
                'Crear Cuenta',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Campo de nombre
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de correo
              TextField(
                controller: _correoController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Campo de usuario
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de contraseña
              TextField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de teléfono
              TextField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Número de Teléfono',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Dropdown de nacionalidad
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _nacionalidadSeleccionada,
                    items: _nacionalidades
                        .map((String nacionalidad) {
                          return DropdownMenuItem<String>(
                            value: nacionalidad,
                            child: Text(nacionalidad),
                          );
                        })
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _nacionalidadSeleccionada = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de IBAN
              TextField(
                controller: _ibanController,
                decoration: const InputDecoration(
                  labelText: 'Número IBAN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
              ),
              const SizedBox(height: 30),

              // Botón de registrar
              ElevatedButton(
                onPressed: _handleRegister,
                child: const Text('Registrar Cuenta'),
              ),
              const SizedBox(height: 16),

              // Botón volver a login
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Volver a Iniciar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
