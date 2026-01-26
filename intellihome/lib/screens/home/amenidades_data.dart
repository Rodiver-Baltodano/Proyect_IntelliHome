import 'package:flutter/material.dart';

class AmenidadItem {
  final int id;
  final String nombre;
  final IconData icono;

  const AmenidadItem({
    required this.id,
    required this.nombre,
    required this.icono,
  });
}

const List<AmenidadItem> amenidadesCatalogo = [
  AmenidadItem(id: 1, nombre: 'Cocina equipada', icono: Icons.kitchen),
  AmenidadItem(id: 2, nombre: 'Aire acondicionado', icono: Icons.ac_unit),
  AmenidadItem(id: 3, nombre: 'Calefacción', icono: Icons.local_fire_department),
  AmenidadItem(id: 4, nombre: 'Wi-Fi gratuito', icono: Icons.wifi),
  AmenidadItem(id: 5, nombre: 'Televisión por cable o satélite', icono: Icons.tv),
  AmenidadItem(id: 6, nombre: 'Lavadora y secadora', icono: Icons.local_laundry_service),
  AmenidadItem(id: 7, nombre: 'Piscina', icono: Icons.pool),
  AmenidadItem(id: 8, nombre: 'Jardín o patio', icono: Icons.park),
  AmenidadItem(id: 9, nombre: 'Barbacoa o parrilla', icono: Icons.outdoor_grill),
  AmenidadItem(id: 10, nombre: 'Terraza o balcón', icono: Icons.balcony),
  AmenidadItem(id: 11, nombre: 'Gimnasio en casa', icono: Icons.fitness_center),
  AmenidadItem(id: 12, nombre: 'Garaje o estacionamiento', icono: Icons.garage),
  AmenidadItem(id: 13, nombre: 'Sistema de seguridad', icono: Icons.security),
  AmenidadItem(id: 14, nombre: 'Baño en suite', icono: Icons.bathtub),
  AmenidadItem(id: 15, nombre: 'Muebles de exterior', icono: Icons.chair_alt),
  AmenidadItem(id: 16, nombre: 'Microondas', icono: Icons.microwave),
  AmenidadItem(id: 17, nombre: 'Lavavajillas', icono: Icons.kitchen),
  AmenidadItem(id: 18, nombre: 'Cafetera', icono: Icons.coffee),
  AmenidadItem(id: 19, nombre: 'Ropa de cama y toallas', icono: Icons.king_bed),
  AmenidadItem(id: 20, nombre: 'Áreas comunes', icono: Icons.apartment),
  AmenidadItem(id: 21, nombre: 'Sofá cama', icono: Icons.weekend),
  AmenidadItem(id: 22, nombre: 'Servicios de limpieza', icono: Icons.cleaning_services),
  AmenidadItem(id: 23, nombre: 'Transporte público cercano', icono: Icons.directions_bus),
  AmenidadItem(id: 24, nombre: 'Mascotas permitidas', icono: Icons.pets),
  AmenidadItem(id: 25, nombre: 'Tiendas y restaurantes', icono: Icons.storefront),
  AmenidadItem(id: 26, nombre: 'Suelo radiante', icono: Icons.heat_pump),
  AmenidadItem(id: 27, nombre: 'Escritorio o área de trabajo', icono: Icons.desk),
  AmenidadItem(id: 28, nombre: 'Entretenimiento', icono: Icons.sports_esports),
  AmenidadItem(id: 29, nombre: 'Chimenea', icono: Icons.fireplace),
  AmenidadItem(id: 30, nombre: 'Internet alta velocidad', icono: Icons.speed),
];
