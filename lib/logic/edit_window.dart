import 'package:kusari/models/date.dart';

bool isEditable(Date target, Date today) {
  return target == today || target == today.previous;
}
