import 'enums.dart';

enum ModifierType { statAdd, armorSpAdd, humanityLossAdd }

class Modifier {
  final ModifierType type;

  // targets
  final StatId? stat;
  final BodyPart? bodyPart;

  final int value;

  const Modifier._(this.type, this.value, {this.stat, this.bodyPart});

  const Modifier.statAdd(StatId stat, int value)
      : this._(ModifierType.statAdd, value, stat: stat);

  const Modifier.armorSpAdd(BodyPart part, int value)
      : this._(ModifierType.armorSpAdd, value, bodyPart: part);

  const Modifier.humanityLossAdd(int value)
      : this._(ModifierType.humanityLossAdd, value);
}
