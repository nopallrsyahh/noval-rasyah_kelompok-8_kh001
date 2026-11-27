/// Mengubah string ISO (yyyy-MM-ddTHH:mm...) menjadi dd/MM/yyyy.
String formatDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '$dd/$mm/${d.year}';
}
