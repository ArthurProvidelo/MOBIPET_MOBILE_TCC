import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_badge.dart';
import '../models/agendamento.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  int _selectedDay = 29;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          // Apple Calendar Style Strip
          Container(
            height: 85,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final dayNum = 25 + index;
                final isSelected = dayNum == _selectedDay;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = dayNum),
                  child: Container(
                    width: 55,
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'][index],
                          style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$dayNum',
                          style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                CustomCard(
                  child: Row(
                    children: [
                      const Column(
                        children: [
                          Text('14:00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('HORA', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                      const VerticalDivider(width: 32),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Banho & Tosa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                CustomBadge(status: StatusAgendamento.agendado),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text('Pet: Thor', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}