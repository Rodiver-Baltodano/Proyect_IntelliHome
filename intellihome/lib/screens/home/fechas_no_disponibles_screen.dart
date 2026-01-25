import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';

class FechasNoDisponiblesScreen extends StatefulWidget {
  final Set<DateTime> initialSelected;

  const FechasNoDisponiblesScreen({super.key, required this.initialSelected});

  @override
  State<FechasNoDisponiblesScreen> createState() =>
      _FechasNoDisponiblesScreenState();
}

class _FechasNoDisponiblesScreenState extends State<FechasNoDisponiblesScreen> {
  late DateTime _visibleMonth;
  late Set<DateTime> _selectedDates;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDates = widget.initialSelected
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
  }

  void _prevMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final weekdayOffset = firstDayOfMonth.weekday % 7; // 0=Sunday
    final today = DateUtils.dateOnly(DateTime.now());

    final monthLabel = _monthName(_visibleMonth.month);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disponibilidad'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Seleccione las fechas no disponibles de su alojamiento',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prevMonth,
                ),
                Text(
                  '$monthLabel ${_visibleMonth.year}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _WeekdayLabel('D'),
                _WeekdayLabel('L'),
                _WeekdayLabel('M'),
                _WeekdayLabel('M'),
                _WeekdayLabel('J'),
                _WeekdayLabel('V'),
                _WeekdayLabel('S'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: daysInMonth + weekdayOffset,
              itemBuilder: (context, index) {
                if (index < weekdayOffset) {
                  return const SizedBox.shrink();
                }
                final day = index - weekdayOffset + 1;
                final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
                final normalized = DateUtils.dateOnly(date);
                final isPast = normalized.isBefore(today);
                final isSelected = _selectedDates.contains(normalized);

                return GestureDetector(
                  onTap: isPast
                      ? null
                      : () {
                          setState(() {
                            if (isSelected) {
                              _selectedDates.remove(normalized);
                            } else {
                              _selectedDates.add(normalized);
                            }
                          });
                        },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isPast
                          ? Colors.grey.shade200
                          : isSelected
                              ? AppColors.primaryColor
                              : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPast
                            ? Colors.grey
                            : isSelected
                                ? Colors.white
                                : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _selectedDates);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Aceptar'),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month - 1];
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;

  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
