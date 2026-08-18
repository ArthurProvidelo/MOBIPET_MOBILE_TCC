abstract class DateFormatters {
  static const _meses = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];

  static const _diasSemana = [
    'segunda-feira', 'terça-feira', 'quarta-feira', 'quinta-feira',
    'sexta-feira', 'sábado', 'domingo',
  ];

  static String dataCurta(DateTime data) {
    return '${_pad(data.day)}/${_pad(data.month)}/${data.year}';
  }

  static String dataLegivel(DateTime data) {
    return '${data.day} ${_meses[data.month - 1]}. ${data.year}';
  }

  static String diaSemanaEData(DateTime data) {
    final nomeDia = _diasSemana[data.weekday - 1];
    final capitalizado = nomeDia[0].toUpperCase() + nomeDia.substring(1);
    return '$capitalizado, ${data.day} de ${_mesCompleto(data.month)}';
  }

  static String hora(DateTime data) {
    return '${_pad(data.hour)}:${_pad(data.minute)}';
  }

  static String dataEHora(DateTime data) {
    return '${dataCurta(data)} às ${hora(data)}';
  }

  static String tempoRelativo(DateTime data) {
    final agora = DateTime.now();
    final diferenca = data.difference(agora);

    if (diferenca.inSeconds.abs() < 60) return 'agora';

    if (diferenca.isNegative) {
      final passado = agora.difference(data);
      if (passado.inMinutes < 60) return 'há ${passado.inMinutes} min';
      if (passado.inHours < 24) return 'há ${passado.inHours} h';
      return 'há ${passado.inDays} dia(s)';
    }

    if (diferenca.inMinutes < 60) return 'em ${diferenca.inMinutes} min';
    if (diferenca.inHours < 24) return 'em ${diferenca.inHours} h';
    return 'em ${diferenca.inDays} dia(s)';
  }

  static String _mesCompleto(int mes) {
    const nomes = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return nomes[mes - 1];
  }

  static String _pad(int value) => value.toString().padLeft(2, '0');
}
