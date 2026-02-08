import 'package:flutter/material.dart';

import 'domain/catalog.dart';
import 'domain/character.dart';
import 'domain/cyberware.dart';
import 'domain/enums.dart';
import 'domain/rules_engine.dart';
import 'domain/storage.dart';

void main() => runApp(const CyberpunkApp());

class CyberpunkApp extends StatelessWidget {
  const CyberpunkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyberpunk 2020 Sheet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final Character _character = Character();
  late final RulesEngine _engine;
  late ComputedCharacter _computed;

  final CharacterStorage _storage = CharacterStorage();

  @override
  void initState() {
    super.initState();
    _engine = RulesEngine(cyberCatalog: Catalog.cyberware);

  // стартовое состояние
  _computed = _engine.compute(_character);

  // загрузка сохранённого персонажа
  _load();
  }

Future<void> _load() async {
  final loaded = await _storage.load();
  if (loaded == null) return;
  setState(() {
    _character.nickname = loaded.nickname;
    _character.role = loaded.role;
    for (final id in StatId.values) {
      _character.stats[id]!.base = loaded.stats[id]!.base;
    }
    _character.humanityBase = loaded.humanityBase;
    _character.humanityLossExtra = loaded.humanityLossExtra;
    _character.cyberware
      ..clear()
      ..addAll(loaded.cyberware);
    _character.wornArmor = loaded.wornArmor;

    _computed = _engine.compute(_character);
  });
}

  void _recompute() {
    setState(() {
      _computed = _engine.compute(_character);
    });
      _storage.save(_character);
  }

  List<Widget> get _pages => [
        const _PlaceholderPage(title: 'Персонаж'),
        StatsPage(character: _character, computed: _computed),
        const _PlaceholderPage(title: 'Навыки'),
        const _PlaceholderPage(title: 'Снаряжение'),
        CyberwarePage(
          character: _character,
          computed: _computed,
          catalog: Catalog.cyberware,
          onChanged: _recompute,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Персонаж',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Статы',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Навыки',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Снаряжение',
          ),
          NavigationDestination(
            icon: Icon(Icons.memory_outlined),
            selectedIcon: Icon(Icons.memory),
            label: 'Кибер',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

class StatsPage extends StatelessWidget {
  final Character character;
  final ComputedCharacter computed;

  const StatsPage({
    super.key,
    required this.character,
    required this.computed,
  });

  @override
  Widget build(BuildContext context) {
    final items = StatId.values;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
children: [
  Text(
    'Humanity: ${computed.humanityCurrent} (loss: ${computed.humanityLossTotal})',
    style: Theme.of(context).textTheme.titleMedium,
  ),
  const SizedBox(height: 12),

  Text(
    'Stat points: ${character.statPointSum} / ${Character.statPointLimit}',
    style: Theme.of(context).textTheme.titleSmall,
  ),
  const SizedBox(height: 8),

  ...items.map((id) {
    final base = character.stats[id]!.base;
    final eff = computed.effectiveStats[id]!;
    final label = statLabel(id);
return ListTile(
  title: Text(label),
  subtitle: Text('base $base → effective $eff'),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: const Icon(Icons.remove),
        onPressed: character.canDecStat(id)
            ? () {
                character.decStat(id);
                (context.findAncestorStateOfType<_HomeShellState>())!
                    ._recompute();
              }
            : null,
      ),
      IconButton(
        icon: const Icon(Icons.add),
        onPressed: character.canIncStat(id)
            ? () {
                character.incStat(id);
                (context.findAncestorStateOfType<_HomeShellState>())!
                    ._recompute();
              }
            : null,
      ),
    ],
  ),
);

          }),
          const SizedBox(height: 12),
          Text(
            'Armor SP (computed)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...BodyPart.values.map((p) {
            final sp = computed.armorSp[p]!;
            return ListTile(
              dense: true,
              title: Text(bodyPartLabel(p)),
              trailing: Text('SP $sp'),
            );
          }),
        ],
      ),
    );
  }
}

class CyberwarePage extends StatelessWidget {
  final Character character;
  final ComputedCharacter computed;
  final List<CyberwareCatalogItem> catalog;
  final VoidCallback onChanged;

  const CyberwarePage({
    super.key,
    required this.character,
    required this.computed,
    required this.catalog,
    required this.onChanged,
  });

  bool _isInstalled(String catalogId) =>
      character.cyberware.any((x) => x.catalogId == catalogId);

  void _toggle(String id) {
    final installed = _isInstalled(id);
    if (installed) {
      character.cyberware.removeWhere((x) => x.catalogId == id);
    } else {
      character.cyberware.add(InstalledCyberware(catalogId: id));
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Installed: ${character.cyberware.length}  •  Humanity: ${computed.humanityCurrent}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...catalog.map((item) {
            final installed = _isInstalled(item.id);
            return Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Text(
                  'slot: ${item.slot} • €${item.price} • HL: ${item.humanityLoss}',
                ),
                trailing: FilledButton(
                  onPressed: () => _toggle(item.id),
                  child: Text(installed ? 'Снять' : 'Установить'),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
