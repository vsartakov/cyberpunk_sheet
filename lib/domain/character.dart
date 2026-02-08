import 'enums.dart';
import 'stat.dart';
import 'cyberware.dart';
import 'armor.dart';

enum Role { solo, rockerboy, netrunner, techie, medtech, media, cop, fixer, nomad, corp }

class Character {
  String nickname = '';
  Role role = Role.solo;

  final Map<StatId, Stat> stats = {
    for (final id in StatId.values) id: Stat(id, 5),
  };

  int humanityBase = 100; // v1: просто базовая шкала
  int humanityLossExtra = 0;

  Armor? wornArmor;

  final List<InstalledCyberware> cyberware = [];

  int baseStat(StatId id) => stats[id]!.base;

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'role': role.name,
      'stats': {
        for (final e in stats.entries) e.key.name: e.value.base,
      },
      'humanityBase': humanityBase,
      'humanityLossExtra': humanityLossExtra,
      'cyberware': [
        for (final c in cyberware)
          {
            'catalogId': c.catalogId,
            'notes': c.notes,
          }
      ],
      'wornArmor': wornArmor == null
          ? null
          : {
              for (final e in wornArmor!.sp.entries) e.key.name: e.value,
            },
    };
  }

  static Character fromJson(Map<String, dynamic> json) {
    final c = Character();
    c.nickname = (json['nickname'] ?? '') as String;

    final roleStr = (json['role'] ?? 'solo') as String;
    c.role = Role.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => Role.solo,
    );

    final statsJson = (json['stats'] as Map?)?.cast<String, dynamic>() ?? {};
    for (final id in StatId.values) {
      final v = statsJson[id.name];
      if (v is int) c.stats[id]!.base = v;
    }

    c.humanityBase = (json['humanityBase'] is int) ? json['humanityBase'] as int : 100;
    c.humanityLossExtra =
        (json['humanityLossExtra'] is int) ? json['humanityLossExtra'] as int : 0;

    final cyberJson = (json['cyberware'] as List?) ?? const [];
    c.cyberware.clear();
    for (final entry in cyberJson) {
      if (entry is Map) {
        final m = entry.cast<String, dynamic>();
        final id = m['catalogId'];
        if (id is String) {
          c.cyberware.add(InstalledCyberware(
            catalogId: id,
            notes: m['notes'] as String?,
          ));
        }
      }
    }

    final armorJson = json['wornArmor'];
    if (armorJson is Map) {
      final sp = <BodyPart, int>{};
      final m = armorJson.cast<String, dynamic>();
      for (final p in BodyPart.values) {
        final v = m[p.name];
        if (v is int) sp[p] = v;
      }
      c.wornArmor = Armor(sp);
    } else {
      c.wornArmor = null;
    }

    return c;
  }
  static const int statMin = 1;
static const int statMax = 10;
static const int statPointLimit = 45;

int get statPointSum =>
    stats.values.fold(0, (sum, s) => sum + s.base);

bool canIncStat(StatId id) {
  final s = stats[id]!;
  if (s.base >= statMax) return false;
  if (statPointSum >= statPointLimit) return false;
  return true;
}

bool canDecStat(StatId id) {
  final s = stats[id]!;
  return s.base > statMin;
}

bool incStat(StatId id) {
  if (!canIncStat(id)) return false;
  stats[id]!.base++;
  return true;
}

bool decStat(StatId id) {
  if (!canDecStat(id)) return false;
  stats[id]!.base--;
  return true;
}
}
