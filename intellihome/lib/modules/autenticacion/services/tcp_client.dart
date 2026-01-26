import 'dart:io';
import 'dart:convert';
import 'dart:async';

class TcpClient {
  Socket? _socket;
  bool _isConnected = false;
  StreamSubscription? _subscription;
  
  // Callback para manejar mensajes recibidos
  Function(String)? onMessageReceived;
  
  // Callback para manejar errores
  Function(dynamic)? onError;
  
  // Callback para manejar desconexión
  Function()? onDisconnected;

  bool get isConnected => _isConnected;

  /// Conecta al servidor TCP
  /// [host] - Dirección IP del servidor (Raspberry Pi Pico W)
  /// [port] - Puerto del servidor (por defecto 8080)
  /// [timeout] - Tiempo de espera para la conexión (por defecto 5 segundos)
  Future<bool> connect(String host, int port, {Duration timeout = const Duration(seconds: 5)}) async {
    try {
      // Cerrar conexión existente si la hay
      if (_isConnected) {
        await disconnect();
      }

      // Intentar conectar con timeout
      _socket = await Socket.connect(
        host, 
        port,
        timeout: timeout,
      );

      _isConnected = true;

      // Escuchar datos del servidor
      _subscription = _socket!.listen(
        (List<int> data) {
          final message = utf8.decode(data).trim();
          if (onMessageReceived != null) {
            onMessageReceived!(message);
          }
        },
        onError: (error) {
          _handleError(error);
        },
        onDone: () {
          _handleDisconnection();
        },
        cancelOnError: true,
      );

      return true;
    } catch (e) {
      _isConnected = false;
      _handleError(e);
      return false;
    }
  }

  /// Envía un mensaje al servidor
  /// [message] - Mensaje a enviar
  Future<bool> sendMessage(String message) async {
    if (!_isConnected || _socket == null) {
      _handleError('No hay conexión con el servidor');
      return false;
    }

    try {
      _socket!.write(message);
      await _socket!.flush();
      return true;
    } catch (e) {
      _handleError('Error al enviar mensaje: $e');
      return false;
    }
  }

  /// Envía datos binarios al servidor
  /// [data] - Datos binarios a enviar
  Future<bool> sendData(List<int> data) async {
    if (!_isConnected || _socket == null) {
      _handleError('No hay conexión con el servidor');
      return false;
    }

    try {
      _socket!.add(data);
      await _socket!.flush();
      return true;
    } catch (e) {
      _handleError('Error al enviar datos: $e');
      return false;
    }
  }

  /// Desconecta del servidor
  Future<void> disconnect() async {
    try {
      await _subscription?.cancel();
      _subscription = null;
      
      await _socket?.close();
      _socket = null;
      
      _isConnected = false;
    } catch (e) {
      _handleError('Error al desconectar: $e');
    }
  }

  /// Maneja errores
  void _handleError(dynamic error) {
    if (onError != null) {
      onError!(error);
    }
  }

  /// Maneja la desconexión
  void _handleDisconnection() {
    _isConnected = false;
    _socket = null;
    _subscription = null;
    
    if (onDisconnected != null) {
      onDisconnected!();
    }
  }

  /// Verifica la conexión enviando un ping
  Future<bool> ping() async {
    if (!_isConnected) return false;
    
    try {
      final result = await sendMessage('PING\n');
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la información de la conexión actual
  String getConnectionInfo() {
    if (_socket == null || !_isConnected) {
      return 'No conectado';
    }
    
    return 'Conectado a ${_socket!.remoteAddress.address}:${_socket!.remotePort}';
  }

  /// Destructor - Limpia recursos
  void dispose() {
    disconnect();
  }
}