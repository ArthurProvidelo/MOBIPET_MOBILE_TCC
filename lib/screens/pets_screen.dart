import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../core/theme/app_colors.dart';
import '../screens/pets_details_screen.dart';

class PetsScreen extends StatelessWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pets', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo Pet', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildPetItem(
            context,
            id: '1',
            name: 'Thor',
            breed: 'Golden Retriever',
            age: '3 anos',
            imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=300',
          ),
          const SizedBox(height: 16),
          _buildPetItem(
            context,
            id: '2',
            name: 'Luna',
            breed: 'Gato Siamês',
            age: '1 ano',
            imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&q=80&w=300',
          ),
        ],
      ),
    );
  }

  Widget _buildPetItem(BuildContext context, {required String id, required String name, required String breed, required String age, required String imageUrl}) {
    return CustomCard(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => PetDetailsScreen(petName: name, imageUrl: imageUrl)));
      },
      child: Row(
        children: [
          Hero(
            tag: 'pet-image-$name',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(breed, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 4),
                Text(age, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 12)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: (value) {},
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 8), Text('Editar')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 20, color: AppColors.danger), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: AppColors.danger))])),
            ],
          ),
        ],
      ),
    );
  }
}