import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/monitoring_session.dart';
import '../../models/pet.dart';
import '../../services/monitoring_service.dart';
import '../../services/pet_repository.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/feedback.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_placeholder.dart';
import '../../widgets/pet_card.dart';

/// Lista de pets do tutor.
class PetsPage extends StatefulWidget {
  const PetsPage({super.key});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openForm({Pet? pet}) async {
    final Object? result = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.petForm, arguments: pet);
    if (!mounted || result is! String) return;
    AppFeedback.success(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final PetRepository repository = context.watch<PetRepository>();
    final MonitoringSession? session = context
        .watch<MonitoringService>()
        .session;
    final List<Pet> pets = repository.pets
        .where(
          (Pet pet) =>
              _query.isEmpty ||
              pet.name.toLowerCase().contains(_query) ||
              pet.breed.toLowerCase().contains(_query),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pets'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () async {
              await repository.refresh();
              if (!context.mounted) return;
              AppFeedback.info(context, 'Lista atualizada.');
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Cadastrar pet'),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: repository.refresh,
          color: AppColors.blue,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
            children: <Widget>[
              TextField(
                controller: _search,
                onChanged: (String value) =>
                    setState(() => _query = value.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou raça',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
              const SizedBox(height: 18),
              if (repository.isLoading)
                const LoadingList()
              else if (repository.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: EmptyState(
                    icon: Icons.pets_rounded,
                    title: 'Nenhum pet cadastrado',
                    message:
                        'Cadastre seu pet para agendar serviços e acompanhar '
                        'cada etapa do atendimento.',
                    actionLabel: 'Cadastrar meu primeiro pet',
                    onAction: () => _openForm(),
                  ),
                )
              else if (pets.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Nada encontrado',
                    message: 'Nenhum pet corresponde a "${_search.text}".',
                  ),
                )
              else
                ...pets.map(
                  (Pet pet) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: PetCard(
                      pet: pet,
                      inService: session?.petId == pet.id,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.petDetails, arguments: pet.id),
                      onEdit: () => _openForm(pet: pet),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
