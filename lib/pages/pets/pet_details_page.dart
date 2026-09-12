import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../navigation/app_page_route.dart';
import '../../state/pets_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pet_avatar.dart';
import '../../widgets/skeleton.dart';
import 'pet_form_page.dart';

class PetDetailsPage extends StatelessWidget {
  final String petId;

  const PetDetailsPage({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PetsProvider>();
    final pet = provider.porId(petId);

    if (pet == null && provider.carregando) {
      return const Scaffold(body: SafeArea(child: _PetDetailsSkeleton()));
    }

    if (pet == null) {
      return const Scaffold(
        body: SafeArea(
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Pet não encontrado',
            message: 'Este pet pode ter sido removido ou já não existe mais.',
          ),
        ),
      );
    }

    final nascimento = DateTime.tryParse(pet.birthDate);
    final nascimentoFormatado =
        nascimento == null ? pet.birthDate : '${nascimento.day.toString().padLeft(2, '0')}/${nascimento.month.toString().padLeft(2, '0')}/${nascimento.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              AppPageRoute.modal((_) => PetFormPage(petId: pet.id)),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Hero(
                tag: 'pet-avatar-${pet.id}',
                child: PetAvatar(pet: pet, size: 96),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text(pet.name, style: Theme.of(context).textTheme.headlineSmall)),
            const SizedBox(height: 8),
            Center(child: CustomBadge(label: pet.status, color: AppColors.accent)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _InfoTile(label: 'Espécie', value: pet.especie, icon: Icons.pets_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _InfoTile(label: 'Porte', value: pet.porte, icon: Icons.straighten_outlined)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _InfoTile(label: 'Raça', value: pet.breed, icon: Icons.category_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _InfoTile(label: 'Nascimento', value: nascimentoFormatado, icon: Icons.calendar_today_outlined)),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmar = await ConfirmDialog.show(
                    context,
                    title: 'Remover pet',
                    message: 'Tem certeza que deseja remover ${pet.name}? Esta ação não pode ser desfeita.',
                    confirmLabel: 'Remover',
                    destructive: true,
                  );
                  if (!context.mounted || !confirmar) return;
                  await context.read<PetsProvider>().remover(pet.id);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${pet.name} foi removido')),
                  );
                },
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: BorderSide(color: AppColors.danger)),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Remover pet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetDetailsSkeleton extends StatelessWidget {
  const _PetDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Center(child: Skeleton.circle(size: 96)),
          SizedBox(height: 20),
          Center(child: Skeleton(width: 140, height: 22)),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: CardSkeleton(linhas: 1)),
              SizedBox(width: 12),
              Expanded(child: CardSkeleton(linhas: 1)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: CardSkeleton(linhas: 1)),
              SizedBox(width: 12),
              Expanded(child: CardSkeleton(linhas: 1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 10),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
