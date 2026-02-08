import 'cyberware.dart';
import 'modifier.dart';
import 'enums.dart';

class Catalog {
  static const cyberware = <CyberwareCatalogItem>[
    CyberwareCatalogItem(
      id: 'skinweave',
      name: 'Skinweave',
      slot: 'body',
      price: 2000,
      humanityLoss: 4,
      modifiers: [
        Modifier.armorSpAdd(BodyPart.torso, 2),
        Modifier.armorSpAdd(BodyPart.rightArm, 1),
        Modifier.armorSpAdd(BodyPart.leftArm, 1),
      ],
    ),
    CyberwareCatalogItem(
      id: 'reflex_booster',
      name: 'Reflex Booster',
      slot: 'neural',
      price: 5000,
      humanityLoss: 8,
      modifiers: [
        Modifier.statAdd(StatId.ref, 1),
      ],
    ),
    CyberwareCatalogItem(
      id: 'cybereye_lowlight',
      name: 'Cybereye (Low-Light)',
      slot: 'eye',
      price: 600,
      humanityLoss: 2,
      modifiers: [
        // пока без модификаторов статов; это “feature” будет позже
      ],
    ),
  ];
}
