/// Nama bulan singkat dalam bahasa Indonesia.
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Mengubah tanggal menjadi teks yang mudah dibaca.
/// Contoh hasil: `24 Nov 2026, 09:05`.
///
/// Sengaja ditulis manual agar tidak perlu menambah package `intl`.
String formatDate(DateTime date) {
  final hh = date.hour.toString().padLeft(2, '0'); // 9 -> "09"
  final mm = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${_months[date.month - 1]} ${date.year}, $hh:$mm';
}
