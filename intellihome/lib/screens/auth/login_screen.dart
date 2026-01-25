import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/l10n/app_localizations.dart';
import 'package:intellihome/providers/language_provider.dart';
import 'package:intellihome/modules/autenticacion/services/autenticacion_service.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:intellihome/providers/theme_provider.dart';
import 'package:intellihome/session/session_manager.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:local_auth/local_auth.dart';
import 'help_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

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
      _autenticacionServicio = AutenticacionServicio(usuarioRepositorio: _repositorio!, context: context);
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
    final loc = AppLocalizations.of(context);
    
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
        SessionManager.setCurrentUserId(resultado.idUsuario ?? '');
        
        final usuario = await _repositorio?.buscarPorId(resultado.idUsuario ?? '');
        if (usuario != null && mounted) {
          context.read<ThemeProvider>().inicializarConUsuario(
            usuario,
            repositorio: _repositorio,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                loc.loginSuccess,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.successColor,
              duration: const Duration(seconds: 2),
            ),
          );

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
        if (mounted) {
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
              content: Text(
                resultado.mensaje,
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
        setState(() {
          _errorPassword = '${loc.error}: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${loc.error}: $e',
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

  void _handleFingerprintLogin() async {
  final loc = AppLocalizations.of(context);
  final username = _usernameController.text.trim();

  // Validar que haya un usuario ingresado
  if (username.isEmpty) {
    setState(() {
      _errorUsername = loc.usernameRequired;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.enterUsername,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.errorColor,
        duration: const Duration(seconds: 2),
      ),
    );
    return;
  }

  try {
    final canAuthenticateWithBiometrics =
        await _localAuth.canCheckBiometrics;
    final canAuthenticate =
        canAuthenticateWithBiometrics ||
        await _localAuth.isDeviceSupported();

    if (!canAuthenticate && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.biometricNotSupported,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final authenticated = await _localAuth.authenticate(
      localizedReason: loc.biometricReason,
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
      ),
    );

    if (authenticated && mounted) {
      setState(() {
        _cargando = true;
        _errorUsername = null;
        _errorPassword = null;
      });

      final usuario =
          await _repositorio?.buscarPorIdentificador(username);

      if (usuario == null) {
        setState(() {
          _errorUsername = loc.userNotFound;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.userNotFound,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.errorColor,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      if (usuario.estaBloqueado) {
        setState(() {
          _errorUsername = loc.userBlocked;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.userBlocked,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      SessionManager.setCurrentUserId(usuario.id);

      if (mounted) {
        context.read<ThemeProvider>().inicializarConUsuario(
          usuario,
          repositorio: _repositorio,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.loginSuccess,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.successColor,
            duration: const Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/home',
              arguments: usuario.username,
            );
          }
        });
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.biometricAuthError,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.errorColor,
          duration: const Duration(seconds: 3),
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
        SizedBox(
          height: 48,
          child: TextField(
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
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
        SizedBox(
          height: 48,
          child: TextField(
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
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
    final loc = AppLocalizations.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(loc.appTitle),
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset(
            'lib/assets/icons/question_mark.png',
            width: 24,
            height: 24,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HelpScreen(),
              ),
            );
          },
          tooltip: loc.help,
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'lib/assets/icons/${languageProvider.currentFlag}',
              width: 29,
              height: 29,
            ),
            onPressed: () async {
              await languageProvider.toggleLanguage();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${loc.language}: ${languageProvider.currentLanguageName}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    duration: const Duration(seconds: 1),
                    backgroundColor: AppColors.primaryColor,
                  ),
                );
              }
            },
            tooltip: loc.language,
          ),
          const SizedBox(width: 11),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
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
                      height: 130,
                      width: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Título
              Text(
                loc.loginTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Campo de usuario
              _buildTextField(
                controller: _usernameController,
                label: loc.username,
                error: _errorUsername,
                icon: Icons.person,
              ),
              const SizedBox(height: 10),

              // Campo de contraseña
              _buildPasswordField(
                controller: _passwordController,
                label: loc.password,
                error: _errorPassword,
                obscureText: !_mostrarPassword,
                onToggleVisibility: () => setState(() => _mostrarPassword = !_mostrarPassword),
                icon: Icons.lock,
              ),
              const SizedBox(height: 8),

              // Botón Olvidé la contraseña
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/recovery',
                      arguments: _usernameController.text.trim(),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  child: Text(
                    loc.forgotPassword,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 0),

              // Botón de huella digital
              Center(
                child: IconButton(
                  icon: const Icon(Icons.fingerprint),
                  iconSize: 64,
                  color: AppColors.primaryColor,
                  onPressed: _handleFingerprintLogin,
                  tooltip: 'Autenticación biométrica',
                ),
              ),
              const SizedBox(height: 8),

              // Botones de login y registrarse
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _cargando ? null : _handleLogin,
                      child: _cargando
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(loc.loginButton),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,  
                        foregroundColor: Colors.white,
                        side: BorderSide(color: AppColors.tertiaryColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(loc.registerButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}