import 'package:flutter/material.dart';

class AmenidadItem {
  final int id;
  final String nombre;
  final String descripcion;
  final IconData icono;

  const AmenidadItem({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
  });
}

const List<AmenidadItem> amenidadesCatalogo = [
  AmenidadItem(
    id: 1,
    nombre: 'Cocina equipada',
    descripcion: 'Incluye utensilios básicos y electrodomésticos esenciales.',
    icono: Icons.kitchen,
  ),
  AmenidadItem(
    id: 2,
    nombre: 'Aire acondicionado',
    descripcion: 'Sistema de climatización para mantener la casa fresca.',
    icono: Icons.ac_unit,
  ),
  AmenidadItem(
    id: 3,
    nombre: 'Calefacción',
    descripcion: 'Ambiente cálido para días fríos.',
    icono: Icons.local_fire_department,
  ),
  AmenidadItem(
    id: 4,
    nombre: 'Wi-Fi gratuito',
    descripcion: 'Conexión a internet incluida durante la estadía.',
    icono: Icons.wifi,
  ),
  AmenidadItem(
    id: 5,
    nombre: 'Televisión por cable o satélite',
    descripcion: 'Acceso a canales nacionales e internacionales.',
    icono: Icons.tv,
  ),
  AmenidadItem(
    id: 6,
    nombre: 'Lavadora y secadora',
    descripcion: 'Facilidades para lavar y secar ropa.',
    icono: Icons.local_laundry_service,
  ),
  AmenidadItem(
    id: 7,
    nombre: 'Piscina',
    descripcion: 'Área de piscina disponible para huéspedes.',
    icono: Icons.pool,
  ),
  AmenidadItem(
    id: 8,
    nombre: 'Jardín o patio',
    descripcion: 'Espacio exterior para descanso o actividades.',
    icono: Icons.park,
  ),
  AmenidadItem(
    id: 9,
    nombre: 'Barbacoa o parrilla',
    descripcion: 'Zona equipada para asados.',
    icono: Icons.outdoor_grill,
  ),
  AmenidadItem(
    id: 10,
    nombre: 'Terraza o balcón',
    descripcion: 'Área abierta con vista o ventilación.',
    icono: Icons.balcony,
  ),
  AmenidadItem(
    id: 11,
    nombre: 'Gimnasio en casa',
    descripcion: 'Equipo básico para ejercicio.',
    icono: Icons.fitness_center,
  ),
  AmenidadItem(
    id: 12,
    nombre: 'Garaje o estacionamiento',
    descripcion: 'Espacio seguro para estacionar vehículos.',
    icono: Icons.garage,
  ),
  AmenidadItem(
    id: 13,
    nombre: 'Sistema de seguridad',
    descripcion: 'Medidas de protección y acceso controlado.',
    icono: Icons.security,
  ),
  AmenidadItem(
    id: 14,
    nombre: 'Baño en suite',
    descripcion: 'Baño privado conectado a la habitación principal.',
    icono: Icons.bathtub,
  ),
  AmenidadItem(
    id: 15,
    nombre: 'Muebles de exterior',
    descripcion: 'Mobiliario para disfrutar espacios al aire libre.',
    icono: Icons.chair_alt,
  ),
  AmenidadItem(
    id: 16,
    nombre: 'Microondas',
    descripcion: 'Para calentar y preparar alimentos rápidamente.',
    icono: Icons.microwave,
  ),
  AmenidadItem(
    id: 17,
    nombre: 'Lavavajillas',
    descripcion: 'Lavado de platos automático.',
    icono: Icons.kitchen,
  ),
  AmenidadItem(
    id: 18,
    nombre: 'Cafetera',
    descripcion: 'Preparación rápida de café.',
    icono: Icons.coffee,
  ),
  AmenidadItem(
    id: 19,
    nombre: 'Ropa de cama y toallas',
    descripcion: 'Incluye sábanas y toallas limpias.',
    icono: Icons.king_bed,
  ),
  AmenidadItem(
    id: 20,
    nombre: 'Áreas comunes',
    descripcion: 'Espacios compartidos disponibles para huéspedes.',
    icono: Icons.apartment,
  ),
  AmenidadItem(
    id: 21,
    nombre: 'Sofá cama',
    descripcion: 'Cama adicional integrada en el sofá.',
    icono: Icons.weekend,
  ),
  AmenidadItem(
    id: 22,
    nombre: 'Servicios de limpieza',
    descripcion: 'Limpieza programada o bajo solicitud.',
    icono: Icons.cleaning_services,
  ),
  AmenidadItem(
    id: 23,
    nombre: 'Transporte público cercano',
    descripcion: 'Acceso rápido a buses o estaciones cercanas.',
    icono: Icons.directions_bus,
  ),
  AmenidadItem(
    id: 24,
    nombre: 'Mascotas permitidas',
    descripcion: 'Alojamiento apto para mascotas.',
    icono: Icons.pets,
  ),
  AmenidadItem(
    id: 25,
    nombre: 'Tiendas y restaurantes',
    descripcion: 'Comercios cercanos para compras y comida.',
    icono: Icons.storefront,
  ),
  AmenidadItem(
    id: 26,
    nombre: 'Suelo radiante',
    descripcion: 'Calefacción uniforme a nivel del piso.',
    icono: Icons.heat_pump,
  ),
  AmenidadItem(
    id: 27,
    nombre: 'Escritorio o área de trabajo',
    descripcion: 'Espacio cómodo para trabajar o estudiar.',
    icono: Icons.desk,
  ),
  AmenidadItem(
    id: 28,
    nombre: 'Entretenimiento',
    descripcion: 'Juegos o equipos de ocio disponibles.',
    icono: Icons.sports_esports,
  ),
  AmenidadItem(
    id: 29,
    nombre: 'Chimenea',
    descripcion: 'Calor adicional y ambiente acogedor.',
    icono: Icons.fireplace,
  ),
  AmenidadItem(
    id: 30,
    nombre: 'Internet alta velocidad',
    descripcion: 'Conexión rápida para streaming y trabajo.',
    icono: Icons.speed,
  ),
];
