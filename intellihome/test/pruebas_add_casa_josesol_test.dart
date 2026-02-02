import 'dart:convert';
import 'dart:io';

import 'package:intellihome/modules/autenticacion/models/usuario.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_azure_blob_repository.dart';

const usersBlobSasUrl =
    'https://intellihomestorage.blob.core.windows.net/data/users.json?sp=rcw&st=2026-02-02T05:25:59Z&se=2026-02-09T13:40:59Z&spr=https&sv=2024-11-04&sr=b&sig=q6pulnKDcmm3lpjiNTV1c64fgGN%2FhrJWYYfER7Tg2gM%3D';

const imagesContainerSasUrl =
    'https://intellihomestorage.blob.core.windows.net/images?sp=rcw&st=2026-02-02T05:31:32Z&se=2026-02-09T13:46:32Z&spr=https&sv=2024-11-04&sr=c&sig=7a1%2FfMUjdE0K5tRryKwGaXQsJ9fWC7BdUT0jcZHdoLE%3D';

Future<void> main() async {
  try {
    final repo = UsuarioAzureBlobRepository(
      usersBlobSasUrl: usersBlobSasUrl,
      imagesContainerSasUrl: imagesContainerSasUrl,
    );

    final usuarios = await repo.cargarUsuarios();
    print('Usuarios cargados: ${usuarios.length}');
    print(const JsonEncoder.withIndent('  ')
        .convert(usuarios.map((u) => u.toJson()).toList()));

    // Ejemplo: subir foto de perfil (reemplazar ruta local)
    final photoPath = r"C:\Users\Jose\Pictures\perro-feliz.jpg";
    String fotoPerfilUrl = '';
    if (photoPath != 'PEGA_AQUI_LA_RUTA_LOCAL_DE_LA_FOTO.jpg') {
      fotoPerfilUrl = await repo.subirFotoPerfil(
        userId: 'user-azure-demo',
        file: File(photoPath),
      );
      print('Foto subida: $fotoPerfilUrl');
    } else {
      print('Reemplaza la ruta local si deseas subir una imagen.');
    }

    // Ejemplo: agregar/actualizar usuario
    final nuevoUsuario = Usuario(
      id: 'user-azure-demo',
      username: 'azure_demo',
      nombreApellidos: 'Usuario Azure Demo',
      correo: 'azure_demo@intellihome.com',
      telefono: '88888888',
      contrasena: 'hash_demo',
      nacionalidad: 'CR',
      numeroIBAN: 'CR00000000000000000000',
      fotoPerfil: fotoPerfilUrl,
      aceptaTerminos: true,
      fechaRegistro: DateTime.now(),
      fechaNacimiento: DateTime(1990, 1, 1),
    );

    await repo.agregarOActualizarUsuario(nuevoUsuario);
    print('Usuario actualizado en Azure Blob.');
  } catch (e) {
    print('Fallo al ejecutar: $e');
  }
}