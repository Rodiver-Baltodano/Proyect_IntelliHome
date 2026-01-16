import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/modules/autenticacion/services/autenticacion_service.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:intellihome/providers/theme_provider.dart';
import 'package:intellihome/session/session_manager.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late AutenticacionServicio _autenticacionServicio;
  UsuarioRepositorioJson? _repositorio;
  bool _inicializado = false;
  bool _cargando = false;
  bool _mostrarPassword = false;
  String? _errorUsername;
  String? _errorPassword;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _inicializarServicios() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final rutaJson = p.join(appDir.path, 'usuarios_integrado.json');
      _repositorio = UsuarioRepositorioJson(rutaArchivo: rutaJson);
      _autenticacionServicio = AutenticacionServicio(usuarioRepositorio: _repositorio!);
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

  void _handleLogin() async {
    setState(() {
      _cargando = true;
      _errorUsername = null;
      _errorPassword = null;
    });

    try {
      final resultado = await _autenticacionServicio.iniciarSesion(
        identificador: _usernameController.text.trim(),
        contrasena: _passwordController.text,
      );

      if (resultado.exito) {
        // Éxito: configurar SessionManager y ThemeProvider
        SessionManager.setCurrentUserId(resultado.idUsuario ?? '');
        
        final usuario = await _repositorio?.buscarPorId(resultado.idUsuario ?? '');
        if (usuario != null && mounted) {
          // Inicializar el ThemeProvider con el usuario logueado
          context.read<ThemeProvider>().inicializarConUsuario(
            usuario,
            repositorio: _repositorio,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Inicio de sesión exitoso!'),
              backgroundColor: AppColors.successColor,
              duration: const Duration(seconds: 2),
            ),
          );

          // Navegar a Home con el username
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pushReplacementNamed(
                context,
                '/home',
                arguments: resultado.username,
              );
            }
          });
        }
      } else {
        // Error
        if (mounted) {
          // Determinar cuál campo mostrar error
          if (resultado.mensaje.contains('usuario') || resultado.mensaje.contains('no existe')) {
            setState(() {
              _errorUsername = resultado.mensaje;
            });
          } else if (resultado.mensaje.contains('bloqueado')) {
            setState(() {
              _errorPassword = resultado.mensaje;
            });
          } else if (resultado.mensaje.contains('Contraseña')) {
            setState(() {
              _errorPassword = resultado.mensaje;
            });
          } else {
            setState(() {
              _errorPassword = resultado.mensaje;
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado.mensaje),
              backgroundColor: AppColors.errorColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorPassword = 'Error: $e';
        });

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

  /// Construye un TextField con validación visual y toggle para contraseñas
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String? error,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    IconData? icon,
  }) {
    final tieneError = error != null && error.isNotEmpty;

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
            error,
            style: TextStyle(
              color: AppColors.errorColor,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  /// Construye un TextField con validación visual
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? error,
    bool obscureText = false,
    IconData? icon,
  }) {
    final tieneError = error != null && error.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
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
            error,
            style: TextStyle(
              color: AppColors.errorColor,
              fontSize: 12,
            ),
          ),
        ],
      ],
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'lib/assets/icons/IntelliHomeLogo.png',
                    height: 160,
                    width: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Título
            Text(
              'Iniciar Sesión',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Campo de usuario
            _buildTextField(
              controller: _usernameController,
              label: 'Usuario',
              error: _errorUsername,
              icon: Icons.person,
            ),
            const SizedBox(height: 20),

            // Campo de contraseña
            _buildPasswordField(
              controller: _passwordController,
              label: 'Contraseña',
              error: _errorPassword,
              obscureText: !_mostrarPassword,
              onToggleVisibility: () => setState(() => _mostrarPassword = !_mostrarPassword),
              icon: Icons.lock,
            ),
            const SizedBox(height: 30),

            // Botones de login y registrarse
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _cargando ? null : _handleLogin,
                    child: _cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Iniciar Sesión'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.tertiaryColor,
                      side: BorderSide(color: AppColors.tertiaryColor, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Registrarse'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botón Olvidé la contraseña
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/recovery',
                  arguments: _usernameController.text.trim(),
                );
              },
              child: Text(
                '¿Olvidé mi contraseña?',
                style: TextStyle(
                  color: AppColors.accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
