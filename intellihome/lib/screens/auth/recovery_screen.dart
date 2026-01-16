import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/modules/autenticacion/services/autenticacion_service.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class RecoveryScreen extends StatefulWidget {
  final String? username;

  const RecoveryScreen({
    super.key,
    this.username,
  });

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final _usuarioController = TextEditingController();
  final _codigoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

  late AutenticacionServicio _autenticacionServicio;
  bool _inicializado = false;
  bool _cargando = false;
  String? _errorUsuario;
  String? _errorCodigo;
  String? _errorContrasena;
  String? _errorConfirmar;
  bool _usuarioIngresado = false;
  bool _mostrarCamposContrasena = false;
  String? _usuarioRecuperando;
  bool _mostrarContrasena = false;
  bool _mostrarConfirmarContrasena = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _inicializarServicios();
      // Si viene username del login, solicitar código automáticamente
      if (widget.username != null && widget.username!.isNotEmpty) {
        _usuarioController.text = widget.username!;
        _usuarioIngresado = true;
        // Solicitar código automáticamente
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _handleSolicitarCodigo();
          }
        });
      }
      _inicializado = true;
    }
  }

  void _inicializarServicios() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final rutaJson = p.join(appDir.path, 'usuarios_integrado.json');
      final repositorio = UsuarioRepositorioJson(rutaArchivo: rutaJson);
      _autenticacionServicio = AutenticacionServicio(usuarioRepositorio: repositorio);
    } catch (e) {
      print('Error inicializando servicios: $e');
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _codigoController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  void _handleSolicitarCodigo() async {
    final usuario = _usuarioController.text.trim();

    if (usuario.isEmpty) {
      setState(() {
        _errorUsuario = 'Por favor ingresa tu teléfono, email o usuario.';
      });
      return;
    }

    setState(() {
      _cargando = true;
      _errorUsuario = null;
    });

    try {
      final resultado = await _autenticacionServicio.solicitarCodigoRecuperacion(
        identificador: usuario,
      );

      if (resultado.exito) {
        if (mounted) {
          setState(() {
            _usuarioIngresado = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Código enviado a tu teléfono!'),
              backgroundColor: AppColors.successColor,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _errorUsuario = resultado.mensaje;
          });

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
          _errorUsuario = 'Error: $e';
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

  void _handleVerificarCodigo() async {
    setState(() {
      _cargando = true;
      _errorCodigo = null;
    });

    try {
      // Aquí asumimos que el usuario ingresó su username o correo
      // Para este ejemplo, solo verificamos el código
      final codigo = _codigoController.text.trim();

      if (codigo.isEmpty) {
        setState(() {
          _errorCodigo = 'El código es requerido';
        });
        return;
      }

      // Obtener el usuario que ya fue ingresado
      String? identificador = _usuarioController.text.trim();
      
      if (identificador.isEmpty) {
        setState(() {
          _errorCodigo = 'Por favor ingresa tu usuario o correo';
        });
        return;
      }

      final resultado = await _autenticacionServicio.verificarCodigoRecuperacion(
        identificador: identificador,
        codigo: codigo,
      );

      if (resultado.exito) {
        if (mounted) {
          setState(() {
            _mostrarCamposContrasena = true;
            _usuarioRecuperando = identificador;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Código verificado! Ahora ingresa tu nueva contraseña.'),
              backgroundColor: AppColors.successColor,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _errorCodigo = resultado.mensaje;
          });

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
          _errorCodigo = 'Error: $e';
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

  void _handleCambiarContrasena() async {
    setState(() {
      _cargando = true;
      _errorContrasena = null;
      _errorConfirmar = null;
    });

    try {
      final contrasena = _contrasenaController.text.trim();
      final confirmar = _confirmarContrasenaController.text.trim();

      // Validar que las contraseñas coincidan
      if (contrasena != confirmar) {
        setState(() {
          _errorConfirmar = 'Las contraseñas no coinciden';
        });
        return;
      }

      if (contrasena.isEmpty || contrasena.length < 8) {
        setState(() {
          _errorContrasena = 'La contraseña debe tener mínimo 8 caracteres';
        });
        return;
      }

      if (_usuarioRecuperando == null) {
        setState(() {
          _errorContrasena = 'Error: usuario no identificado';
        });
        return;
      }

      final resultado = await _autenticacionServicio.actualizarContrasenaConCodigo(
        identificador: _usuarioRecuperando!,
        codigo: _codigoController.text.trim(),
        nuevaContrasena: contrasena,
      );

      if (resultado.exito) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Contraseña actualizada! Regresa a login.'),
              backgroundColor: AppColors.successColor,
              duration: const Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorContrasena = resultado.mensaje;
          });

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
          _errorContrasena = 'Error: $e';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IntelliHome'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
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
                'Recupere su Cuenta',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Descripción
              Text(
                _usuarioIngresado
                    ? 'Por favor ingrese el código que le hemos enviado a su correo'
                    : 'Ingrese su usuario o correo para recibir un código de recuperación',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Paso 1: Ingresar usuario/correo (solo si no viene del login)
              if (!_usuarioIngresado) ...[
                _buildTextField(
                  controller: _usuarioController,
                  label: 'Usuario o Correo',
                  error: _errorUsuario,
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _cargando ? null : _handleSolicitarCodigo,
                  child: _cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Solicitar Código'),
                ),
              ] else if (_cargando && !_mostrarCamposContrasena) ...[
                // Indicador de que se está solicitando código
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Solicitando código...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primaryColor,
                            ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],

              // Paso 2: Ingresar código
              if (_usuarioIngresado && !_mostrarCamposContrasena && !_cargando) ...[
                _buildTextField(
                  controller: _codigoController,
                  label: 'Código de Recuperación',
                  error: _errorCodigo,
                  icon: Icons.vpn_key,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _cargando ? null : _handleVerificarCodigo,
                  child: _cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Verificar Código'),
                ),
              ],

              // Campos de nueva contraseña (aparecen después de verificar código)
              if (_mostrarCamposContrasena) ...[
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _contrasenaController,
                  label: 'Nueva Contraseña',
                  error: _errorContrasena,
                  obscureText: !_mostrarContrasena,
                  onToggleVisibility: () => setState(() => _mostrarContrasena = !_mostrarContrasena),
                  icon: Icons.lock,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _confirmarContrasenaController,
                  label: 'Confirmar Contraseña',
                  error: _errorConfirmar,
                  obscureText: !_mostrarConfirmarContrasena,
                  onToggleVisibility: () => setState(() => _mostrarConfirmarContrasena = !_mostrarConfirmarContrasena),
                  icon: Icons.lock_outline,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _cargando ? null : _handleCambiarContrasena,
                  child: _cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Cambiar mi Contraseña'),
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
                child: const Text('Volver a Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
