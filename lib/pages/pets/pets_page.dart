import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../navigation/app_page_route.dart';
import '../../state/pets_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/pet_card.dart';
import 'pet_acompanhamento_page.dart';
import 'pet_details_page.dart';
import 'pet_form_page.dart';

class PetsPage extends StatelessWidget {
  const PetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PetsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Pets')),
      body: SafeArea(
        child: provider.carregando
            ? const LoadingView()
            : provider.pets.isEmpty
                ? EmptyState(
                    icon: Icons.pets_rounded,
                    title: 'Nenhum pet cadastrado',
                    message: 'Cadastre seu primeiro pet para acompanhar os atendimentos.',
                    actionLabel: 'Cadastrar pet',
                    onAction: () => Navigator.of(context).push(
                      AppPageRoute.modal((_) => const PetFormPage()),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: provider.carregar,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: provider.pets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final pet = provider.pets[index];
                        return Dismissible(
                          key: ValueKey(pet.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: AppColors.white),
                          ),
                          confirmDismiss: (_) => ConfirmDialog.show(
                            context,
                            title: 'Remover pet',
                            message: 'Tem certeza que deseja remover ${pet.name}? Esta ação não pode ser desfeita.',
                            confirmLabel: 'Remover',
                            destructive: true,
                          ),
                          onDismissed: (_) async {
                            await context.read<PetsProvider>().remover(pet.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${pet.name} foi removido')),
                            );
                          },
                          child: PetCard(
                            pet: pet,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => PetDetailsPage(petId: pet.id)),
                            ),
                            onEdit: () => Navigator.of(context).push(
                              AppPageRoute.modal((_) => PetFormPage(petId: pet.id)),
                            ),
                            onAcompanhar: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => PetAcompanhamentoPage(petId: pet.id)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          AppPageRoute.modal((_) => const PetFormPage()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo pet'),
      ),
    );
  }
}
