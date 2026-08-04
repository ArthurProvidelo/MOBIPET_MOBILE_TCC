import 'package:intl/intl.dart';

/// Formatações em pt-BR usadas em todo o app.
class Formatters {
  const Formatters._();

  static final DateFormat _date = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final DateFormat _dateShort = DateFormat("d 'de' MMM", 'pt_BR');
  static final DateFormat _dateLong = DateFormat("d 'de' MMMM 'de' y", 'pt_BR');
  static final DateFormat _weekday = DateFormat('EEEE', 'pt_BR');
  static final DateFormat _time = DateFormat('HH:mm', 'pt_BR');
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static String date(DateTime value) => _date.format(value);

  static String dateShort(DateTime value) => _dateShort.format(value);

  static String dateLong(DateTime value) => _dateLong.format(value);

  static String time(DateTime value) => _time.format(value);

  static String weekday(DateTime value) => _capitalize(_weekday.format(value));

  static String currency(double value) => _currency.format(value);

  /// "Hoje, 09:00" / "Amanhã, 14:30" / "qua, 12 de mar · 10:00"
  static String friendlyDateTime(DateTime value) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime target = DateTime(value.year, value.month, value.day);
    final int diff = target.difference(today).inDays;
    if (diff == 0) return 'Hoje, ${time(value)}';
    if (diff == 1) return 'Amanhã, ${time(value)}';
    if (diff == -1) return 'Ontem, ${time(value)}';
    return '${dateShort(value)} · ${time(value)}';
  }

  /// "há 12 min" / "há 2 h"
  static String relative(DateTime value) {
    final Duration diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours} h';
    return 'há ${diff.inDays} d';
  }

  /// "1h 20min" a partir de uma duração.
  static String duration(Duration value) {
    final int hours = value.inHours;
    final int minutes = value.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}min';
    return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}min';
  }

  static String greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
