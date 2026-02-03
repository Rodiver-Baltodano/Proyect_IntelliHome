import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/modules/finanzas/models/pago.dart';
import 'package:intellihome/modules/finanzas/repositories/pago_repository.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  late Future<List<Pago>> _pagosFuture;

  @override
  void initState() {
    super.initState();
    _pagosFuture = _cargarPagos();
  }

  Future<List<Pago>> _cargarPagos() async {
    final appDir = await getApplicationDocumentsDirectory();
    final rutaJson = p.join(appDir.path, 'pagos_integrado.json');
    final repo = PagoRepositorioJson(rutaArchivo: rutaJson);
    return repo.cargarPagos();
  }

  String _formatPrecio(double precio) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(precio);
  }

  Widget _buildResumenCard({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Pago>>(
        future: _pagosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar pagos: ${snapshot.error}'),
            );
          }

          final pagos = snapshot.data ?? [];
          if (pagos.isEmpty) {
            return const Center(
              child: Text('No hay pagos registrados aún.'),
            );
          }

          final totalArrendamiento =
              pagos.fold<double>(0, (sum, p) => sum + p.montoArrendamiento);
          final totalComision =
              pagos.fold<double>(0, (sum, p) => sum + p.comision);
          final totalIva = pagos.fold<double>(0, (sum, p) => sum + p.iva);
          final totalAjuste = pagos.fold<double>(0, (sum, p) => sum + p.ajuste);
          final totalPagado = pagos.fold<double>(0, (sum, p) => sum + p.total);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Resumen global de ganancias',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildResumenCard(
                label: 'Monto total de arrendamientos',
                value: '₡${_formatPrecio(totalArrendamiento)}',
              ),
              const SizedBox(height: 10),
              _buildResumenCard(
                label: 'Comisiones acumuladas',
                value: '₡${_formatPrecio(totalComision)}',
              ),
              const SizedBox(height: 10),
              _buildResumenCard(
                label: 'IVA acumulado sobre comisiones',
                value: '₡${_formatPrecio(totalIva)}',
              ),
              const SizedBox(height: 10),
              _buildResumenCard(
                label: 'Ajuste financiero dinámico',
                value: '₡${_formatPrecio(totalAjuste)}',
              ),
              const SizedBox(height: 10),
              _buildResumenCard(
                label: 'Total pagado',
                value: '₡${_formatPrecio(totalPagado)}',
              ),
              const SizedBox(height: 18),
              const Text(
                'Detalle de pagos',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...pagos.map(
                (pago) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(pago.nombreCasa.isNotEmpty
                      ? pago.nombreCasa
                      : pago.propertyId),
                  subtitle: Text(
                    'Reserva ${pago.reservationId} • ${DateFormat('dd/MM/yyyy').format(pago.fecha)}',
                  ),
                  trailing: Text('₡${_formatPrecio(pago.total)}'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
