import 'package:intl/intl.dart';

final _money = NumberFormat.currency(symbol: '฿', decimalDigits: 2);
final _moneyCompact = NumberFormat.compactCurrency(symbol: '฿', decimalDigits: 0);

const _monthsFull = [
  'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
  'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
];
const _monthsShort = [
  'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
  'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
];
// DateTime.weekday: 1 = Monday ... 7 = Sunday
const _weekdaysShort = ['จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.'];

/// Buddhist Era year (พ.ศ.)
int beYear(int year) => year + 543;

String formatMoney(double v) => _money.format(v);
String formatCompact(double v) => _moneyCompact.format(v);

/// e.g. 4 พ.ย. 2569
String formatDate(DateTime d) =>
    '${d.day} ${_monthsShort[d.month - 1]} ${beYear(d.year)}';

/// e.g. พฤศจิกายน 2569
String formatMonth(DateTime d) =>
    '${_monthsFull[d.month - 1]} ${beYear(d.year)}';

/// e.g. พ.ย.
String formatMonthShort(int month) => _monthsShort[month - 1];

/// e.g. พ.
String formatWeekday(DateTime d) => _weekdaysShort[d.weekday - 1];

String formatDayHeader(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'วันนี้';
  if (diff == 1) return 'เมื่อวาน';
  return '${formatWeekday(d)} ${formatDate(d)}';
}
