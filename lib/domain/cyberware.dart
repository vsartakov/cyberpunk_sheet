import 'modifier.dart';

class CyberwareCatalogItem {
  final String id;
  final String name;
  final String slot; // "body", "eye", ...
  final int price;
  final int humanityLoss;
  final List<Modifier> modifiers;

  const CyberwareCatalogItem({
    required this.id,
    required this.name,
    required this.slot,
    required this.price,
    required this.humanityLoss,
    required this.modifiers,
  });
}

class InstalledCyberware {
  final String catalogId;
  final String? notes;

  const InstalledCyberware({required this.catalogId, this.notes});
}
