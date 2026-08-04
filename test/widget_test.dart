import 'package:flutter_test/flutter_test.dart';
import 'package:mobipet_mobile/models/monitoring_session.dart';
import 'package:mobipet_mobile/models/pet.dart';
import 'package:mobipet_mobile/models/service_stage.dart';
import 'package:mobipet_mobile/services/mock_data.dart';
import 'package:mobipet_mobile/services/monitoring_service.dart';

void main() {
  group('Pet', () {
    test('calcula a idade em anos completos', () {
      final DateTime now = DateTime.now();
      final Pet pet = Pet(
        id: '1',
        name: 'Thor',
        breed: 'Golden Retriever',
        birthDate: DateTime(now.year - 3, now.month, now.day),
        species: PetSpecies.dog,
        size: PetSize.large,
        weightKg: 32,
      );
      expect(pet.ageInYears, 3);
      expect(pet.ageLabel, '3 anos');
    });

    test('serializa e desserializa mantendo os dados', () {
      final Pet pet = MockData.pets().first;
      final Pet restored = Pet.fromJson(pet.toJson());
      expect(restored.name, pet.name);
      expect(restored.rfidTag, pet.rfidTag);
      expect(restored.size, pet.size);
    });
  });

  group('MonitoringSession', () {
    test('progresso reflete as leituras registradas', () {
      final MonitoringSession session = MockData.session();
      expect(session.completedCount, 3);
      expect(session.totalCount, ServiceStage.fullFlow.length);
      expect(session.currentStage, ServiceStage.drying);
      expect(session.nextStage, ServiceStage.grooming);
      expect(session.isFinished, isFalse);
    });
  });

  group('MonitoringService', () {
    test('cada leitura RFID avança uma etapa até finalizar', () {
      final MonitoringService service = MonitoringService();
      final int remaining =
          service.lastSession.totalCount - service.lastSession.completedCount;

      for (int i = 0; i < remaining; i++) {
        expect(service.registerRfidRead(), isNotNull);
      }

      expect(service.lastSession.isFinished, isTrue);
      expect(service.registerRfidRead(), isNull);
      expect(service.session, isNull);
      service.dispose();
    });
  });
}
