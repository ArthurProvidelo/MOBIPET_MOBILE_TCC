import '../models/agendamento.dart';
import '../models/atendimento.dart';
import '../models/pet.dart';
import '../models/servico.dart';
import '../models/usuario.dart';

/// Fonte única de dados mockados do app. Nenhuma chamada de rede é feita —
/// tudo aqui simula o que viria de uma futura API Laravel.
abstract class MockData {
  static const String donoId = 'u1';

  static final Usuario usuario = Usuario(
    id: donoId,
    nome: 'João Silva',
    email: 'joao.silva@email.com',
    telefone: '(11) 98765-4321',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
  );

  static final List<Pet> pets = [
    Pet(
      id: 'p1',
      donoId: donoId,
      name: 'Thor',
      breed: 'Golden Retriever',
      age: '3 anos',
      gender: 'Macho',
      weight: 28,
      birthDate: '12/04/2022',
      imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=400',
      notes: 'Alergia leve a xampus com fragrância forte. Dócil durante a tosa, porém necessita de cuidado extra ao cortar as unhas.',
    ),
    Pet(
      id: 'p2',
      donoId: donoId,
      name: 'Luna',
      breed: 'Shih Tzu',
      age: '1 ano',
      gender: 'Fêmea',
      weight: 6.4,
      birthDate: '03/08/2024',
      imageUrl: 'https://images.unsplash.com/photo-1591768575198-88dac53fbd0a?auto=format&fit=crop&q=80&w=400',
      notes: 'Pelagem exige escovação frequente. Um pouco agitada durante o banho.',
    ),
    Pet(
      id: 'p3',
      donoId: donoId,
      name: 'Mel',
      breed: 'Labrador',
      age: '5 anos',
      gender: 'Fêmea',
      weight: 26,
      birthDate: '20/01/2020',
      imageUrl: 'https://images.unsplash.com/photo-1633722715463-d30f4f325e24?auto=format&fit=crop&q=80&w=400',
      notes: 'Sem restrições especiais. Muito tranquila durante todo o atendimento.',
    ),
  ];

  static final List<Servico> servicos = [
    const Servico(
      id: 's1',
      nome: 'Banho',
      duracaoEstimada: Duration(minutes: 45),
      preco: 60,
      descricao: 'Banho completo com xampu neutro e secagem.',
    ),
    const Servico(
      id: 's2',
      nome: 'Banho e Tosa',
      duracaoEstimada: Duration(minutes: 90),
      preco: 110,
      descricao: 'Banho completo seguido de tosa higiênica ou na tesoura.',
    ),
    const Servico(
      id: 's3',
      nome: 'Hidratação',
      duracaoEstimada: Duration(minutes: 60),
      preco: 80,
      descricao: 'Hidratação profunda para pelagem ressecada.',
    ),
    const Servico(
      id: 's4',
      nome: 'Tosa Higiênica',
      duracaoEstimada: Duration(minutes: 40),
      preco: 50,
      descricao: 'Tosa das áreas íntimas, patas e face.',
    ),
  ];

  static final List<Agendamento> agendamentos = [
    Agendamento(
      id: 'a1',
      petId: 'p1',
      servicoId: 's2',
      dateTime: DateTime.now().add(const Duration(hours: 2)),
      status: StatusAgendamento.agendado,
      atendimentoId: 'at1',
    ),
    Agendamento(
      id: 'a2',
      petId: 'p2',
      servicoId: 's1',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
      status: StatusAgendamento.agendado,
    ),
    Agendamento(
      id: 'a3',
      petId: 'p3',
      servicoId: 's3',
      dateTime: DateTime.now().add(const Duration(days: 4)),
      status: StatusAgendamento.agendado,
    ),
    Agendamento(
      id: 'a4',
      petId: 'p1',
      servicoId: 's4',
      dateTime: DateTime.now().subtract(const Duration(days: 6)),
      status: StatusAgendamento.concluido,
    ),
  ];

  /// Atendimento em andamento já com algumas etapas concluídas, para a Home
  /// não abrir vazia e a demonstração poder avançar as etapas restantes ao vivo.
  static Atendimento atendimentoAtual = Atendimento(
    id: 'at1',
    petId: 'p1',
    servicoId: 's2',
    agendamentoId: 'a1',
    etapaAtual: EtapaAtendimento.secagem,
    historico: [
      EtapaTimestamp(etapa: EtapaAtendimento.checkIn, concluidaEm: DateTime.now().subtract(const Duration(minutes: 40))),
      EtapaTimestamp(etapa: EtapaAtendimento.banho, concluidaEm: DateTime.now().subtract(const Duration(minutes: 20))),
      EtapaTimestamp(etapa: EtapaAtendimento.secagem, concluidaEm: DateTime.now().subtract(const Duration(minutes: 2))),
    ],
    iniciadoEm: DateTime.now().subtract(const Duration(minutes: 40)),
  );
}
