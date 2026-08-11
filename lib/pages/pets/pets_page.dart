import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/pets_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/pet_card.dart';
import 'pet_details_page.dart';
import 'pet_form_page.dart';

class PetsPage extends StatelessWidget {
  const PetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final petsProvider = context.watch<PetsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Pets')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-pets',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PetFormPage(mode: PetFormMode.create)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Novo Pet'),
      ),
      body: petsProvider.isLoading
          ? const LoadingView()
          : petsProvider.pets.isEmpty
              ? Center(
                  child: EmptyState(
                    icon: Icons.pets_outlined,
                    title: 'Nenhum pet cadastrado ainda',
                    subtitle: 'Cadastre seu primeiro pet para começar a acompanhar os atendimentos.',
                    actionLabel: 'Cadastrar pet',
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PetFormPage(mode: PetFormMode.create)),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: petsProvider.pets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final pet = petsProvider.pets[index];
                    return PetCard(
                      pet: pet,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PetDetailsPage(pet: pet)),
                      ),
                      onEdit: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => PetFormPage(mode: PetFormMode.edit, pet: pet)),
                      ),
                      onDelete: () async {
                        final confirmar = await showConfirmDialog(
                          context,
                          title: 'Excluir ${pet.name}?',
                          message: 'Essa ação não pode ser desfeita.',
                          confirmLabel: 'Excluir',
                          danger: true,
                        );
                        if (!context.mounted || !confirmar) return;
                        await context.read<PetsProvider>().remover(pet.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${pet.name} foi removido'), backgroundColor: AppColors.textPrimary),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
