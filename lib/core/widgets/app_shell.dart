import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../constants/design_tokens.dart';
import 'app_background.dart';
import 'brand_mark.dart';

class SeletoDestination {
  const SeletoDestination(
    this.section,
    this.icon,
    this.selectedIcon,
    this.label,
    this.route,
    this.permission,
  );
  final String section;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
  final String permission;
}

class _DestinationSection {
  const _DestinationSection(this.label, this.items);
  final String label;
  final List<_DestinationItem> items;
}

class _DestinationItem {
  const _DestinationItem(
    this.icon,
    this.selectedIcon,
    this.label,
    this.route,
    this.permission,
  );
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
  final String permission;
}

const _destinationSections = <_DestinationSection>[
  _DestinationSection('INÍCIO', [
    _DestinationItem(
      Icons.dashboard_outlined,
      Icons.dashboard,
      'Visão geral',
      '/dashboard',
      'dashboard.view',
    ),
  ]),
  _DestinationSection('PLANTEL E OVOS', [
    _DestinationItem(
      Icons.egg_alt_outlined,
      Icons.egg_alt,
      'Lotes',
      '/lots',
      'lots.view',
    ),
    _DestinationItem(
      Icons.swap_horiz_outlined,
      Icons.swap_horiz,
      'Movimentações',
      '/movements',
      'lots.view',
    ),
    _DestinationItem(
      Icons.inventory_2_outlined,
      Icons.inventory_2,
      'Coleta',
      '/egg-collection',
      'egg_collection.view',
    ),
    _DestinationItem(
      Icons.egg_outlined,
      Icons.egg,
      'Estoque de ovos',
      '/egg-stock',
      'egg_stock.view',
    ),
  ]),
  _DestinationSection('MANEJO', [
    _DestinationItem(
      Icons.restaurant_outlined,
      Icons.restaurant,
      'Ração e alimentação',
      '/feed',
      'feeding.view',
    ),
    _DestinationItem(
      Icons.calendar_month_outlined,
      Icons.calendar_month,
      'Calendário e luz',
      '/calendar',
      'calendar.view',
    ),
  ]),
  _DestinationSection('COMERCIAL', [
    _DestinationItem(
      Icons.storefront_outlined,
      Icons.storefront,
      'Comercial',
      '/commercial',
      'orders.view',
    ),
  ]),
  _DestinationSection('FINANCEIRO', [
    _DestinationItem(
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet,
      'Financeiro',
      '/finance',
      'finance.view',
    ),
  ]),
  _DestinationSection('GESTÃO', [
    _DestinationItem(
      Icons.query_stats_outlined,
      Icons.query_stats,
      'Relatórios',
      '/reports',
      'reports.view',
    ),
  ]),
  _DestinationSection('SISTEMA', [
    _DestinationItem(
      Icons.notifications_active_outlined,
      Icons.notifications_active,
      'Alertas',
      '/alerts',
      'alerts.view',
    ),
    _DestinationItem(
      Icons.people_outline,
      Icons.people,
      'Usuários',
      '/users',
      'users.view',
    ),
    _DestinationItem(
      Icons.settings_outlined,
      Icons.settings,
      'Configurações',
      '/settings',
      'settings.view',
    ),
    _DestinationItem(
      Icons.history_outlined,
      Icons.history,
      'Auditoria',
      '/audit',
      'audit.view',
    ),
  ]),
];

final seletoDestinations = [
  for (final section in _destinationSections)
    for (final item in section.items)
      SeletoDestination(
        section.label,
        item.icon,
        item.selectedIcon,
        item.label,
        item.route,
        item.permission,
      ),
];

List<MapEntry<String, List<SeletoDestination>>> _groupedDestinations(
  List<SeletoDestination> destinations,
) {
  final grouped = <String, List<SeletoDestination>>{};
  for (final destination in destinations) {
    grouped.putIfAbsent(destination.section, () => []).add(destination);
  }
  return grouped.entries.toList();
}

String _backgroundForPath(String path) {
  if (path == '/dashboard') {
    return 'assets/images/backgrounds/bg_caipira_orange_yolk.png';
  }
  if (path == '/feed') return 'assets/images/backgrounds/bg_feed.png';
  if (path == '/egg-collection' || path == '/egg-stock') {
    return 'assets/images/backgrounds/bg_eggs.png';
  }
  if (path == '/commercial' || path == '/finance' || path == '/reports') {
    return 'assets/images/backgrounds/bg_management.png';
  }
  if (path == '/alerts') return 'assets/images/backgrounds/bg_management.png';
  if (path == '/users' || path == '/settings' || path == '/audit') {
    return 'assets/images/backgrounds/bg_management.png';
  }
  return 'assets/images/backgrounds/bg_production.png';
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.title,
    this.scrollable = true,
  });
  final Widget child;
  final String title;
  final bool scrollable;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openMenu() => _scaffoldKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final path = GoRouterState.of(context).uri.path;
    final session = ref.watch(authControllerProvider).session;
    final destinations = seletoDestinations
        .where((d) => session?.allows(d.permission) ?? false)
        .toList();
    final mobile = width < SeletoTokens.compactBreakpoint;
    final horizontalPadding = width < 600 ? 16.0 : 28.0;
    Widget content({double? height}) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: SeletoTokens.contentMaxWidth),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            48,
          ),
          child: widget.child,
        ),
      ),
    );
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: mobile
            ? IconButton(
                tooltip: 'Menu',
                icon: const Icon(Icons.menu_rounded),
                onPressed: _openMenu,
              )
            : null,
        title: Text(widget.title),
        centerTitle: false,
        actions: [
          if (!mobile)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    session?.displayName.split(' ').first ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(authControllerProvider).signOut();
              context.go('/login');
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: mobile
          ? Drawer(
              child: SafeArea(
                child: _DrawerNavigation(
                  destinations: destinations,
                  path: path,
                ),
              ),
            )
          : null,
      body: SeletoAppBackground(
        imagePath: _backgroundForPath(path),
        alignment: path == '/dashboard'
            ? Alignment.centerRight
            : Alignment.center,
        child: Row(
          children: [
            if (!mobile)
              _SideNavigation(
                destinations: destinations,
                path: path,
                extended: width >= 1120,
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final page = content(
                    height: widget.scrollable ? null : constraints.maxHeight,
                  );
                  if (!widget.scrollable) return Center(child: page);
                  return Center(child: SingleChildScrollView(child: page));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideNavigation extends StatelessWidget {
  const _SideNavigation({
    required this.destinations,
    required this.path,
    required this.extended,
  });
  final List<SeletoDestination> destinations;
  final String path;
  final bool extended;
  @override
  Widget build(BuildContext context) {
    final groups = _groupedDestinations(destinations);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: extended ? 272 : 80,
      child: Material(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerLow.withValues(alpha: .94),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: extended ? 18 : 16,
                vertical: 8,
              ),
              child: BrandMark(compact: !extended),
            ),
            const SizedBox(height: 12),
            for (
              var groupIndex = 0;
              groupIndex < groups.length;
              groupIndex++
            ) ...[
              if (!extended)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    groupIndex == 0 ? 0 : 10,
                    16,
                    6,
                  ),
                  child: Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 5),
                  child: Text(
                    groups[groupIndex].key,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              for (final d in groups[groupIndex].value)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Tooltip(
                    message: d.label,
                    child: ListTile(
                      selected: path == d.route,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: .52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: extended ? 12 : 16,
                      ),
                      minLeadingWidth: 24,
                      horizontalTitleGap: 12,
                      visualDensity: VisualDensity.compact,
                      leading: Icon(path == d.route ? d.selectedIcon : d.icon),
                      iconColor: path == d.route
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      title: extended
                          ? Text(d.label, overflow: TextOverflow.ellipsis)
                          : null,
                      onTap: path == d.route ? null : () => context.go(d.route),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DrawerNavigation extends StatelessWidget {
  const _DrawerNavigation({required this.destinations, required this.path});
  final List<SeletoDestination> destinations;
  final String path;
  @override
  Widget build(BuildContext context) {
    final groups = _groupedDestinations(destinations);
    return Column(
      children: [
        const Padding(padding: EdgeInsets.all(20), child: BrandMark()),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (final group in groups) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 5),
                  child: Text(
                    group.key,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                for (final d in group.value)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    child: ListTile(
                      selected: path == d.route,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: .52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: Icon(path == d.route ? d.selectedIcon : d.icon),
                      iconColor: path == d.route
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      title: Text(d.label),
                      onTap: () {
                        Navigator.pop(context);
                        if (path != d.route) context.go(d.route);
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
