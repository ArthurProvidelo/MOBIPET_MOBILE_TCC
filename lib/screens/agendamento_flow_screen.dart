import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AgendamentoFlowScreen extends StatefulWidget {
  const AgendamentoFlowScreen({super.key});

  @override
  State<AgendamentoFlowScreen> createState() => _AgendamentoFlowScreenState();
}

class _AgendamentoFlowScreenState extends State<AgendamentoFlowScreen> {
  int _currentStep = 0;
  String? _selectedService = 'Banho & Tosa';
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime = '14:00';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: Colors.grey.shade200,
            color: AppColors.primary,
          ),
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildStepService(),
                _buildStepDate(),
                _buildStepConfirm(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Voltar'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_currentStep == 2 ? 'Confirmar' : 'Próximo', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepService() {
    final services = ['Banho Simples', 'Banho & Tosa', 'Consulta Veterinária', 'Corte de Unhas'];
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final s = services[index];
        final isSelected = _selectedService == s;
        return Card(
          elevation: 0,
          color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey.shade200),
          ),
          child: ListTile(
            title: Text(s, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
            onTap: () => setState(() => _selectedService = s),
          ),
        );
      },
    );
  }

  Widget _buildStepDate() {
    return Column(
      children: [
        CalendarDatePicker(
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 60)),
          onDateChanged: (date) => setState(() => _selectedDate = date),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(alignment: Alignment.centerLeft, child: Text('Horários disponíveis', style: TextStyle(fontWeight: FontWeight.bold))),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: ['09:00', '11:00', '14:00', '16:00'].map((time) {
            final isSel = _selectedTime == time;
            return ChoiceChip(
              label: Text(time),
              selected: isSel,
              selectedColor: AppColors.primary.withOpacity(0.2),
              onSelected: (_) => setState(() => _selectedTime = time),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStepConfirm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumo do Agendamento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          _summaryRow('Serviço:', _selectedService ?? ''),
          _summaryRow('Data:', '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
          _summaryRow('Horário:', _selectedTime ?? ''),
          _summaryRow('Pet:', 'Thor'),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}