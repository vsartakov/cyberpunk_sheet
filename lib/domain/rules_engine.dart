import 'character.dart';
import 'cyberware.dart';
import 'enums.dart';
import 'modifier.dart';

class ComputedCharacter {
  final Map<StatId, int> effectiveStats;
  final Map<BodyPart, int> armorSp;
  final int humanityLossTotal;
  final int humanityCurrent;

  const ComputedCharacter({
    required this.effectiveStats,
    required this.armorSp,
    required this.humanityLossTotal,
    required this.humanityCurrent,
  });
}

class RulesEngine {
  final Map<String, CyberwareCatalogItem> cyberCatalogById;

  RulesEngine({required List<CyberwareCatalogItem> cyberCatalog})
      : cyberCatalogById = {for (final c in cyberCatalog) c.id: c};

  ComputedCharacter compute(Character c) {
    final statAdd = {for (final id in StatId.values) id: 0};
    final armorAdd = {for (final p in BodyPart.values) p: 0};

    int humanityLoss = c.humanityLossExtra;

    // armor base
    final baseArmorSp = {for (final p in BodyPart.values) p: 0};
    final worn = c.wornArmor;
    if (worn != null) {
      for (final entry in worn.sp.entries) {
        baseArmorSp[entry.key] = entry.value;
      }
    }

    // apply cyber modifiers
    for (final installed in c.cyberware) {
      final item = cyberCatalogById[installed.catalogId];
      if (item == null) continue;

      humanityLoss += item.humanityLoss;

      for (final m in item.modifiers) {
        switch (m.type) {
          case ModifierType.statAdd:
            if (m.stat != null) statAdd[m.stat!] = statAdd[m.stat!]! + m.value;
            break;
          case ModifierType.armorSpAdd:
            if (m.bodyPart != null) armorAdd[m.bodyPart!] = armorAdd[m.bodyPart!]! + m.value;
            break;
          case ModifierType.humanityLossAdd:
            humanityLoss += m.value;
            break;
        }
      }
    }

    final effectiveStats = <StatId, int>{
      for (final id in StatId.values) id: c.baseStat(id) + statAdd[id]!,
    };

    final armorSp = <BodyPart, int>{
      for (final p in BodyPart.values) p: baseArmorSp[p]! + armorAdd[p]!,
    };

    final humanityCurrent = (c.humanityBase - humanityLoss).clamp(0, c.humanityBase);

    return ComputedCharacter(
      effectiveStats: effectiveStats,
      armorSp: armorSp,
      humanityLossTotal: humanityLoss,
      humanityCurrent: humanityCurrent,
    );
  }
}
