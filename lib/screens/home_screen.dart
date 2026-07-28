import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_badge.dart';
import '../models/agendamento.dart';
import 'agendamento_flow_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Olá, Carlos 👋', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text('Tudo certo com seus pets hoje?', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Agendamento CTA
            CustomCard(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AgendamentoFlowScreen()));
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.add_task, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Agendar Serviço', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Banho, tosa ou consulta em 1 min', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Próximo Agendamento
            Text('Próximo Agendamento', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Banho & Tosa Completa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      CustomBadge(status: StatusAgendamento.agendado),
                    ],
                  ),
                  const Divider(height: 24),
                  const Row(
                    children: [
                      Icon(Icons.pets, size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text('Thor (Golden Retriever)', style: TextStyle(color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text('Amanhã, 14:00', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Resumo dos Pets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Meus Pets (2)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildPetQuickCard('Thor', 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=300'),
                  const SizedBox(width: 12),
                  _buildPetQuickCard('Luna', 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&q=80&w=300'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetQuickCard(String name, String imageUrl) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}