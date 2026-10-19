const habitNameMaxLength = 50;

String? validateHabitName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return '名前を入力してください';
  }
  if (trimmed.length > habitNameMaxLength) {
    return '$habitNameMaxLength文字以内で入力してください';
  }
  return null;
}
