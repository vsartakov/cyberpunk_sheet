import 'enums.dart';

class Armor {
  // SP per body location (base from armor itself)
  final Map<BodyPart, int> sp;

  const Armor(this.sp);
}
