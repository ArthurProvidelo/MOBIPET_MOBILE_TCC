import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/custom_card.dart';
import 'agendamento_flow_screen.dart';

class PetDetailsScreen extends StatelessWidget {
  final String petName;
  final String imageUrl;

  const PetDetailsScreen({super.key, required this.petName, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(petName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'pet-image-$petName',
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildInfoTile('Sexo', 'Macho')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInfoTile('Peso', '28 kg')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInfoTile('Nascimento', '12/04/2021')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Observações & Cuidados Especial', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                  const SizedBox(height: 12),
                  const CustomCard(
                    child: Text(
                      'Alergia leve a xampus com fragrância forte. O pet costuma ser dócil durante a tosa, porém necessita de cuidado extra ao cortar as unhas.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AgendamentoFlowScreen()));
                      },
                      icon: const Icon(Icons.calendar_month, color: Colors.white),
                      label: const Text('Agendar Serviço', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}