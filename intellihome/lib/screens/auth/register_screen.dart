import 'package:flutter/material.dart';
import 'package:intellihome/modules/autenticacion/services/registro_service.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:intellihome/widgets/custom_input_field.dart';
import 'package:intellihome/widgets/custom_button.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _usernameController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmContrasenaController = TextEditingController();
  final _nacionalidadController = TextEditingController();
  final _ibanController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _aceptaTerminos = false;
  bool _isLoading = false;
  String? _errorMessage;

  late RegistroServicio _registroServicio;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeServices();
      _initialized = true;
    }
  }

  void _initializeServices() async {
    final appDir = await getApplicationDocumentsDirectory();
    final rutaJson = p.join(appDir.path, 'usuarios_integrado.json');
    final repositorio = UsuarioRepositorioJson(rutaArchivo: rutaJson);
    _registroServicio = RegistroServicio(repositorio: repositorio);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _usernameController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _contrasenaController.dispose();
    _confirmContrasenaController.dispose();
    _nacionalidadController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_contrasenaController.text != _confirmContrasenaController.text) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final resultado = await _registroServicio.registrarUsuario(
        nombreApellidos: _nombreController.text.trim(),
        username: _usernameController.text.trim(),
        correo: _correoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        contrasena: _contrasenaController.text,
        nacionalidad: _nacionalidadController.text.trim(),
        numeroIBAN: _ibanController.text.trim(),
        fotoPerfil: 'https://via.placeholder.com/150',
        aceptaTerminos: _aceptaTerminos,
      );

      if (resultado.exito) {
        // Registro exitoso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido ${resultado.usuario?.username}!'),
              backgroundColor: Colors.green,
            ),
          );
          // TODO: Navigate to home screen or login
          // Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        setState(() {
          _errorMessage = resultado.errores.values.join(', ');
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Center(
                child: Text(
                  'Registro IntelliHome',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 24),

              // Nombre completo
              CustomInputField(
                label: 'Nombre Completo',
                hint: 'Juan Pérez García',
                controller: _nombreController,
                prefixIcon: const Icon(Icons.person),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre requerido';
                  }
                  if (value.split(' ').length < 2) {
                    return 'Ingresa tu nombre completo';
                  }
                  return null;
                },
              ),

              // Username
              CustomInputField(
                label: 'Usuario (Username)',
                hint: 'juanperez123',
                controller: _usernameController,
                prefixIcon: const Icon(Icons.account_box),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Usuario requerido';
                  }
                  if (value.length < 5) {
                    return 'Mínimo 5 caracteres';
                  }
                  return null;
                },
              ),

              // Email
              CustomInputField(
                label: 'Correo Electrónico',
                hint: 'juan@example.com',
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email requerido';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),

              // Teléfono
              CustomInputField(
                label: 'Teléfono',
                hint: '87654321',
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Teléfono requerido';
                  }
                  if (value.length < 7) {
                    return 'Teléfono inválido';
                  }
                  return null;
                },
              ),

              // Nacionalidad
              CustomInputField(
                label: 'Nacionalidad',
                hint: 'Costa Rica',
                controller: _nacionalidadController,
                prefixIcon: const Icon(Icons.public),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nacionalidad requerida';
                  }
                  return null;
                },
              ),

              // IBAN
              CustomInputField(
                label: 'Número IBAN',
                hint: 'CR2400123456789012345678',
                controller: _ibanController,
                prefixIcon: const Icon(Icons.credit_card),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'IBAN requerido';
                  }
                  if (value.length < 20) {
                    return 'IBAN inválido';
                  }
                  return null;
                },
              ),

              // Contraseña
              CustomInputField(
                label: 'Contraseña',
                hint: 'Mínimo 8 caracteres',
                controller: _contrasenaController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contraseña requerida';
                  }
                  if (value.length < 8) {
                    return 'Mínimo 8 caracteres';
                  }
                  return null;
                },
              ),

              // Confirmar contraseña
              CustomInputField(
                label: 'Confirmar Contraseña',
                hint: 'Repite tu contraseña',
                controller: _confirmContrasenaController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirmación requerida';
                  }
                  return null;
                },
              ),

              // Checkbox de términos
              Row(
                children: [
                  Checkbox(
                    value: _aceptaTerminos,
                    onChanged: (value) {
                      setState(() {
                        _aceptaTerminos = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Acepto los términos y condiciones',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mensaje de error
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),

              // Botón de registro
              CustomButton(
                label: 'Crear Cuenta',
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),

              const SizedBox(height: 16),

              // Enlace a login
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes cuenta? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate back to login
                        // Navigator.of(context).pop();
                      },
                      child: Text(
                        'Inicia sesión',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
