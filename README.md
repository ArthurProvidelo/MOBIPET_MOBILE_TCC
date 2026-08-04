# MOBIPET Monitoramento

Aplicativo mobile (Flutter) para clientes de pet shop acompanharem, em tempo real,
o atendimento dos seus pets e realizarem agendamentos.

Cada pet recebe um cartão RFID na chegada ao pet shop. A cada aproximação do cartão
no leitor conectado ao ESP32, o atendimento avança uma etapa:

`Check-in → Banho → Secagem → Tosa → Escovação → Perfume → Pronto para retirada → Finalizado`

> Protótipo de TCC: **100% frontend**, com dados mockados (sem backend, sem Firebase,
> sem API e sem banco de dados), organizado para integração futura com uma API Laravel.

## Como executar

```bash
flutter pub get
flutter run            # Android/iOS
flutter run -d chrome  # Web
```

Credenciais de demonstração (já preenchidas na tela de login):

- E-mail: `joao.silva@email.com`
- Senha: `123456`

Qualidade:

```bash
flutter analyze
flutter test
```

## Telas

Splash, Login, Criar conta, Recuperação de senha, Home, Meus Pets, Cadastro de pet,
Editar pet, Detalhes do pet, Agendamentos, Novo agendamento, Detalhes do serviço,
Perfil, Editar perfil e Alterar senha, com bottom navigation entre Home, Meus Pets,
Agenda e Perfil.

## Estrutura

```text
lib/
  models/     # Pet, Appointment, PetService, ServiceStage, MonitoringSession, AppUser
  pages/      # telas agrupadas por fluxo (auth, home, pets, appointments, profile)
  services/   # AuthService, PetRepository, AppointmentRepository, MonitoringService, MockData
  theme/      # cores da marca e tema Material 3
  utils/      # rotas, validações, máscaras, formatadores e feedback (SnackBars/diálogos)
  widgets/    # componentes reutilizáveis (cards, timeline RFID, progresso, estados vazios)
```

## Integração futura com a API Laravel

- Todos os modelos já possuem `fromJson`/`toJson` com os nomes de campos esperados no backend.
- Os dados fixos ficam isolados em `lib/services/mock_data.dart`.
- Os serviços (`AuthService`, `PetRepository`, `AppointmentRepository`, `MonitoringService`)
  concentram o acesso aos dados e são assíncronos: basta trocar o corpo dos métodos por
  chamadas HTTP mantendo as mesmas assinaturas.
- O avanço das etapas em `MonitoringService.registerRfidRead()` corresponde ao evento que o
  ESP32 enviará ao backend (ex.: `POST /api/rfid/read`), consumido por polling ou WebSocket.

## Identidade visual

| Uso | Cor |
| --- | --- |
| Azul | `#2D5D96` |
| Azul claro | `#58B8E8` |
| Laranja | `#F59A23` |
| Branco | `#FFFFFF` |
| Fundo | `#F7F9FC` |
| Texto | `#243B53` |
| Texto secundário | `#6B7280` |

Material Design 3, fonte Poppins, cantos arredondados, sombras suaves e animações discretas.
