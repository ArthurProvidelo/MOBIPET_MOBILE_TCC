import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../navigation/app_page_route.dart';
import '../../state/pets_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/haptics.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_slide_in.dart';
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
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: provider.carregar,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar.large(
                title: const Text('Meus Pets'),
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                titleTextStyle: Theme.of(context).textTheme.headlineLarge,
              ),
              if (provider.carregando)
                const SliverFillRemaining(hasScrollBody: false, child: LoadingView())
              else if (provider.pets.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.pets_rounded,
                    title: 'Nenhum pet cadastrado',
                    message: 'Cadastre seu primeiro pet para acompanhar os atendimentos.',
                    actionLabel: 'Cadastrar pet',
                    onAction: () => Navigator.of(context).push(
                      AppPageRoute.modal((_) => const PetFormPage()),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: provider.pets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final pet = provider.pets[index];
                      return FadeSlideIn(
                        delay: Duration(milliseconds: (index * 55).clamp(0, 330)),
                        offsetY: 16,
                        child: Dismissible(
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
                            Haptics.success();
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
                        ),
                      );
                    },
                  ),
                ),
            ],
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
