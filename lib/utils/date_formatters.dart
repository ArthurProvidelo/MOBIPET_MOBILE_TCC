abstract class DateFormatters {
  static const _meses = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  static const _diasSemana = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  static String data(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String dataCurta(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_meses[date.month - 1]}';
  }

  static String hora(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String diaSemana(DateTime date) => _diasSemana[date.weekday - 1];

  static String relativoAoDia(DateTime date, {DateTime? agora}) {
    final now = agora ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Hoje, ${hora(date)}';
    if (diff == 1) return 'Amanhã, ${hora(date)}';
    if (diff > 1 && diff <= 6) return '${diaSemana(date)}, ${hora(date)}';
    return '${data(date)}, ${hora(date)}';
  }

  static String grupoDoDia(DateTime date, {DateTime? agora}) {
    final now = agora ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Amanhã';
    if (diff > 1 && diff <= 6) return 'Esta semana';
    if (diff < 0) return 'Anteriores';
    return data(date);
  }
}
