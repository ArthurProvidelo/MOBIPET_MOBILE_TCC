import 'package:flutter/material.dart';
import '../../models/pet.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../agendamentos/novo_agendamento_page.dart';
import 'pet_form_page.dart';

class PetDetailsPage extends StatelessWidget {
  final Pet pet;

  const PetDetailsPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PetFormPage(mode: PetFormMode.edit, pet: pet)),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(pet.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'pet-image-${pet.id}',
                    child: Image.network(pet.imageUrl, fit: BoxFit.cover),
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
                  Text(pet.breed, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildInfoTile('Sexo', pet.gender)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInfoTile('Peso', '${pet.weight} kg')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInfoTile('Nascimento', pet.birthDate)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Observações & Cuidados Especiais', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                  const SizedBox(height: 12),
                  CustomCard(
                    child: Text(
                      pet.notes.isNotEmpty ? pet.notes : 'Nenhuma observação registrada.',
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => NovoAgendamentoPage(petIdPreSelecionado: pet.id)),
                    ),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Agendar Serviço'),
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
        border: Border.all(color: AppColors.border),
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
