import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/modules/autenticacion/services/registro_service.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';

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
  bool _aceptaTerminos = false;
  File? _imagenPerfil;
  String? _rutaFoto;
  
  late RegistroServicio _registroServicio;
  bool _inicializado = false;
  bool _cargando = false;
  Map<String, String> _erroresValidacion = {};
  
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

  void _inicializarServicios() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final rutaJson = p.join(appDir.path, 'usuarios_integrado.json');
      final repositorio = UsuarioRepositorioJson(rutaArchivo: rutaJson);
      _registroServicio = RegistroServicio(repositorio: repositorio);
    } catch (e) {
      print('Error inicializando servicios: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _inicializarServicios();
      _inicializado = true;
    }
  }

  void _handleRegister() async {
    setState(() {
      _cargando = true;
      _erroresValidacion = {};
    });

    try {
      // Usar ruta de la foto o un placeholder
      final fotoPerfil = _rutaFoto ?? 'https://via.placeholder.com/150';

      final resultado = await _registroServicio.registrarUsuario(
        nombreApellidos: _nombreController.text.trim(),
        username: _usernameController.text.trim(),
        correo: _correoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        contrasena: _contrasenaController.text,
        nacionalidad: _nacionalidadSeleccionada,
        numeroIBAN: _ibanController.text.trim(),
        fotoPerfil: fotoPerfil,
        aceptaTerminos: _aceptaTerminos,
      );

      if (resultado.exito) {
        // Éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido ${resultado.usuario?.username}!'),
              backgroundColor: AppColors.successColor,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Limpiar formulario
          _nombreController.clear();
          _correoController.clear();
          _usernameController.clear();
          _contrasenaController.clear();
          _telefonoController.clear();
          _ibanController.clear();
          setState(() {
            _imagenPerfil = null;
            _rutaFoto = null;
            _aceptaTerminos = false;
          });

          // Navegar a login después de 2 segundos
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
        }
      } else {
        // Error(es)
        if (mounted) {
          setState(() {
            _erroresValidacion = resultado.errores;
          });

          // Mostrar mensaje de error principal
          final primerError = resultado.errores.values.first;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(primerError),
              backgroundColor: AppColors.errorColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  void _handleTerminosAndCondiciones() {
    print('Hipervinculo de Términos y Condiciones presionado');
  }

  /// Construye un TextField con validación visual
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String fieldKey,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? icon,
  }) {
    final tieneError = _erroresValidacion.containsKey(fieldKey);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: tieneError ? AppColors.errorColor : AppColors.secondaryColor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: tieneError ? AppColors.errorColor : AppColors.primaryColor,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: tieneError ? AppColors.errorColor : Colors.grey,
                width: tieneError ? 2 : 1,
              ),
            ),
            prefixIcon: Icon(
              icon,
              color: tieneError ? AppColors.errorColor : AppColors.secondaryColor,
            ),
          ),
        ),
        if (tieneError) ...[
          const SizedBox(height: 4),
          Text(
            _erroresValidacion[fieldKey] ?? '',
            style: TextStyle(
              color: AppColors.errorColor,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _seleccionarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (imagen != null) {
      await _guardarFoto(File(imagen.path));
    }
  }

  Future<void> _guardarFoto(File archivoFoto) async {
    try {
      // Obtener directorio de la app
      final appDir = await getApplicationDocumentsDirectory();
      
      // Crear carpeta 'profiles' si no existe
      final carpetaProfiles = Directory(p.join(appDir.path, 'profiles'));
      if (!await carpetaProfiles.exists()) {
        await carpetaProfiles.create(recursive: true);
      }

      // Generar nombre único para la foto
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final nombreFoto = 'perfil_$timestamp.jpg';
      
      // Guardar foto en la carpeta profiles
      final rutaDestino = p.join(carpetaProfiles.path, nombreFoto);
      final fotoGuardada = await archivoFoto.copy(rutaDestino);

      setState(() {
        _imagenPerfil = fotoGuardada;
        _rutaFoto = rutaDestino;
      });

      print('Foto guardada en: $rutaDestino');
    } catch (e) {
      print('Error al guardar foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              // Foto de perfil circular con +
              Center(
                child: GestureDetector(
                  onTap: _seleccionarFoto,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 3,
                          ),
                        ),
                        child: _imagenPerfil != null
                            ? ClipOval(
                                child: Image.file(
                                  _imagenPerfil!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[600],
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentColor,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Leyenda de registro
              Text(
                'Registrarse a IntelliHome',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Campo de nombre
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre',
                fieldKey: 'nombreApellidos',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              // Campo de correo
              _buildTextField(
                controller: _correoController,
                label: 'Correo Electrónico',
                fieldKey: 'correo',
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email,
              ),
              const SizedBox(height: 16),

              // Campo de usuario
              _buildTextField(
                controller: _usernameController,
                label: 'Usuario',
                fieldKey: 'username',
                icon: Icons.account_circle,
              ),
              const SizedBox(height: 16),

              // Campo de contraseña
              _buildTextField(
                controller: _contrasenaController,
                label: 'Contraseña',
                fieldKey: 'contrasena',
                obscureText: true,
                icon: Icons.lock,
              ),
              const SizedBox(height: 16),

              // Campo de teléfono
              _buildTextField(
                controller: _telefonoController,
                label: 'Número de Teléfono',
                fieldKey: 'telefono',
                keyboardType: TextInputType.phone,
                icon: Icons.phone,
              ),
              const SizedBox(height: 16),

              // Dropdown de nacionalidad
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.secondaryColor),
                  borderRadius: BorderRadius.circular(8),
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
              _buildTextField(
                controller: _ibanController,
                label: 'Número IBAN',
                fieldKey: 'numeroIBAN',
                icon: Icons.credit_card,
              ),
              const SizedBox(height: 30),

              // Botón de registrar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _cargando ? null : _handleRegister,
                child: _cargando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Registrar Cuenta'),
              ),
              const SizedBox(height: 20),

              // Texto de términos y condiciones
              Center(
                child: Text(
                  'Como último paso, le invitamos a leer nuestros',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),

              // Checkbox y hipervinculo de términos
              Row(
                children: [
                  Checkbox(
                    value: _aceptaTerminos,
                    activeColor: AppColors.primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _aceptaTerminos = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _handleTerminosAndCondiciones,
                      child: Text(
                        'Términos y condiciones',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.accentColor,
                              decoration: TextDecoration.underline,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Botón volver a login
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.tertiaryColor,
                  side: BorderSide(color: AppColors.tertiaryColor, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
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
