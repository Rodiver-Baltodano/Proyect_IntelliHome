import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/modules/autenticacion/services/registro_service.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_azure_blob_repository.dart';
import 'terms_screen.dart';
import 'package:intellihome/l10n/app_localizations.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _usernameController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _ibanController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();

  String _nacionalidadSeleccionada = 'Costa Rica';
  bool _aceptaTerminos = false;
  bool _terminosAceptadosEnModal = false;
  bool _mostrarContrasena = false;
  bool _mostrarConfirmarContrasena = false;
  bool _mostrarTarjeta = false;
  File? _imagenPerfil;
  String? _rutaFoto;
  DateTime? _fechaNacimiento;
  
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
    _confirmarContrasenaController.dispose();
    _telefonoController.dispose();
    _ibanController.dispose();
    _fechaNacimientoController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cedulaController.dispose(); 
    super.dispose();
  }

  void _inicializarServicios() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final rutaJson = p.join(appDir.path, 'usuarios_integrado.json');
      final repositorio = UsuarioRepositorioJson(rutaArchivo: rutaJson);
      _registroServicio = RegistroServicio(
        repositorio: 
          repositorio, 
          context: context
        );
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

    

    if (_fechaNacimiento == null) {
      setState(() {
        _erroresValidacion['fechaNacimiento'] = 'Selecciona tu fecha de nacimiento';
        _cargando = false;
      });
      return;
    }

    // Validar que las contraseñas coincidan
    if (_contrasenaController.text != _confirmarContrasenaController.text) {
      setState(() {
        _erroresValidacion['contrasena'] = 'Las contraseñas no coinciden';
        _cargando = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).passwordsDontMatch),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
      return;
    }
    // Validar términos y condiciones
    if (!_aceptaTerminos || !_terminosAceptadosEnModal) {
      setState(() {
        _cargando = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).mustAcceptTermsError,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
      return;
    }

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
        fechaNacimiento: _fechaNacimiento!,
        numeroTarjeta: _cardNumberController.text.trim(),
        fechaExpiracion: _cardExpiryController.text.trim(),
        cvv: _cardCvvController.text.trim(),
        cedula: _cedulaController.text.trim(),
      );

      if (resultado.exito) {
        // Éxito
        if (mounted) {
          final username = resultado.usuario?.username ?? 'Usuario';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppLocalizations.of(context).registrationSuccess} $username',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.successColor,
              duration: const Duration(seconds: 2),
            ),
          );

          // Limpiar formulario
          _nombreController.clear();
          _correoController.clear();
          _usernameController.clear();
          _contrasenaController.clear();
          _confirmarContrasenaController.clear();
          _telefonoController.clear();
          _ibanController.clear();
          _fechaNacimientoController.clear();
          _cardNumberController.clear();
          _cardExpiryController.clear();
          _cardCvvController.clear();
          _cedulaController.clear();
          setState(() {
            _imagenPerfil = null;
            _rutaFoto = null;
            _aceptaTerminos = false;
            _fechaNacimiento = null;
            _mostrarTarjeta = false;
          });

          // Navegar a Personalización después de 2 segundos
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacementNamed(
                context,
                '/personalizacion',
                arguments: {
                  'username': username,
                  'fromRegister': true,
                },
              );
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
              content: Text(
                primerError, 
                style: const TextStyle(color: Colors.white),
              ),
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
            content: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.white),
            ),
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

  Future<void> _handleTerminosAndCondiciones() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const TermsUI(),
      ),
    );

    if (resultado == true) {
      setState(() {
        _terminosAceptadosEnModal = true;
        _aceptaTerminos = true;
      });
    }
  }

  /// Construye un TextField con validación visual y toggle de visibilidad para contraseñas
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String fieldKey,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    IconData? icon,
  }) {
    final tieneError = _erroresValidacion.containsKey(fieldKey);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: TextInputType.visiblePassword,
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
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppColors.secondaryColor,
              ),
              onPressed: onToggleVisibility,
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

  Future<void> _seleccionarFechaNacimiento() async {
    final hoy = DateTime.now();
    final fechaInicial = DateTime(hoy.year - 18, hoy.month, hoy.day);
    final seleccion = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: hoy,
    );

    if (seleccion != null) {
      setState(() {
        _fechaNacimiento = seleccion;
        final dia = seleccion.day.toString().padLeft(2, '0');
        final mes = seleccion.month.toString().padLeft(2, '0');
        _fechaNacimientoController.text = '$dia/$mes/${seleccion.year}';
        _erroresValidacion.remove('fechaNacimiento');
      });
    }
  }

  /// Construye un TextField con validación visual
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String fieldKey,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final tieneError = _erroresValidacion.containsKey(fieldKey);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
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
      final usersUrl = dotenv.env['USERS_BLOB_SAS_URL'] ?? '';
      final imagesUrl = dotenv.env['IMAGES_CONTAINER_SAS_URL'] ?? '';
      final usarAzure = usersUrl.isNotEmpty && imagesUrl.isNotEmpty;

      if (usarAzure) {
        final repo = UsuarioAzureBlobRepository(
          usersBlobSasUrl: usersUrl,
          imagesContainerSasUrl: imagesUrl,
        );

        final userId = _usernameController.text.trim().isNotEmpty
            ? _usernameController.text.trim()
            : DateTime.now().millisecondsSinceEpoch.toString();

        final url = await repo.subirFotoPerfil(
          userId: userId,
          file: archivoFoto,
        );

        setState(() {
          _imagenPerfil = archivoFoto;
          _rutaFoto = url;
        });

        print('Foto subida a Azure: $url');
        return;
      }

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
            content: Text(
              'Error al guardar foto: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: 
        AppBar(
          title: Text(AppLocalizations.of(context).appTitle),
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
                AppLocalizations.of(context).registerTitle,
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
                label: AppLocalizations.of(context).name,
                fieldKey: 'nombreApellidos',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              // Campo de correo
             _buildTextField(
                controller: _correoController,
                label: AppLocalizations.of(context).email,
                fieldKey: 'correo',
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email,
              ),
              const SizedBox(height: 16),

              // Campo de usuario
              _buildTextField(
                controller: _usernameController,
                label: AppLocalizations.of(context).username,
                fieldKey: 'username',
                icon: Icons.account_circle,
              ),
              const SizedBox(height: 16),

              // Fecha de nacimiento
              _buildTextField(
                controller: _fechaNacimientoController,
                label: AppLocalizations.of(context).birthDate,
                fieldKey: 'fechaNacimiento',
                icon: Icons.cake,
                readOnly: true,
                onTap: _seleccionarFechaNacimiento,
              ),
              const SizedBox(height: 16),

              // Campo de contraseña
              _buildPasswordField(
                controller: _contrasenaController,
                label: AppLocalizations.of(context).password,
                fieldKey: 'contrasena',
                obscureText: !_mostrarContrasena,
                onToggleVisibility: () => setState(() => _mostrarContrasena = !_mostrarContrasena),
                icon: Icons.lock,
              ),
              const SizedBox(height: 16),

              // Campo de confirmar contraseña
              _buildPasswordField(
                controller: _confirmarContrasenaController,
                label: AppLocalizations.of(context).confirmPassword,
                fieldKey: 'confirmarContrasena',
                obscureText: !_mostrarConfirmarContrasena,
                onToggleVisibility: () => setState(() => _mostrarConfirmarContrasena = !_mostrarConfirmarContrasena),
                icon: Icons.lock,
              ),
              const SizedBox(height: 16),

              // Campo de teléfono
              _buildTextField(
                controller: _telefonoController,
                label: AppLocalizations.of(context).phoneNumber,
                fieldKey: 'telefono',
                keyboardType: TextInputType.phone,
                icon: Icons.phone,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _cedulaController,
                label: AppLocalizations.of(context).idNumber,
                fieldKey: 'cedula',
                keyboardType: TextInputType.number,
                icon: Icons.credit_card_outlined,
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
                    hint: Text(AppLocalizations.of(context).nationality),
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
                label: AppLocalizations.of(context).ibanNumber,
                fieldKey: 'numeroIBAN',
                icon: Icons.credit_card,
              ),
              const SizedBox(height: 16),

              // Tarjeta de crédito/débito (opcional)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.secondaryColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ExpansionTile(
                  title: Text(AppLocalizations.of(context).addCreditCard),
                  trailing: Icon(_mostrarTarjeta ? Icons.expand_less : Icons.expand_more),
                  initiallyExpanded: _mostrarTarjeta,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _mostrarTarjeta = expanded;
                    });
                  },
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _buildTextField(
                      controller: _cardNumberController,
                      label: AppLocalizations.of(context).cardNumber,
                      fieldKey: 'numeroTarjeta',
                      keyboardType: TextInputType.number,
                      icon: Icons.credit_card,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cardExpiryController,
                            label: AppLocalizations.of(context).expirationDate,
                            fieldKey: 'fechaExpiracion',
                            keyboardType: TextInputType.datetime,
                            icon: Icons.date_range,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _cardCvvController,
                            label: AppLocalizations.of(context).cvv,
                            fieldKey: 'cvv',
                            keyboardType: TextInputType.number,
                            icon: Icons.lock_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).cardOptionalNote,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryColor),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 30),

              // Botón de registrar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_aceptaTerminos && _terminosAceptadosEnModal)
                      ? AppColors.primaryColor
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: (_cargando || !_aceptaTerminos || !_terminosAceptadosEnModal)
                    ? null
                    : _handleRegister,
                child: _cargando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(AppLocalizations.of(context).registerAccount),
              ),
              const SizedBox(height: 20),

              // Texto de términos y condiciones
              Center(
                child: Text(
                  AppLocalizations.of(context).termsMessage,
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
                    value: _aceptaTerminos && _terminosAceptadosEnModal,
                    activeColor: AppColors.primaryColor,
                    onChanged: null, // Deshabilitado, solo se activa desde el modal
                  ),
                  Expanded(
                    child: 
                    GestureDetector(
                      onTap: _handleTerminosAndCondiciones,
                      child: Text(
                        AppLocalizations.of(context).termsAndConditions,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (!_terminosAceptadosEnModal) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 48),
                  child: Text(
                    AppLocalizations.of(context).mustAcceptTerms,
                    style: TextStyle(
                      color: AppColors.errorColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
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
                child: Text(AppLocalizations.of(context).backToLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
