import 'package:flutter/material.dart';

class SeletoPageHeader extends StatelessWidget {
  const SeletoPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });
  final String title;
  final String subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final textWidth = constraints.maxWidth < 680
          ? constraints.maxWidth
          : 680.0;
      return Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          SizedBox(
            width: textWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ?action,
        ],
      );
    },
  );
}

class SeletoEmptyState extends StatelessWidget {
  const SeletoEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    ),
  );
}

class SeletoKpiCard extends StatelessWidget {
  const SeletoKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeletoKpiGrid extends StatelessWidget {
  const SeletoKpiGrid({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final columns = box.maxWidth >= 1050
          ? 4
          : box.maxWidth >= 650
          ? 2
          : 1;
      return GridView.count(
        crossAxisCount: columns,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: columns == 1 ? 3.1 : 1.8,
        children: children,
      );
    },
  );
}

class SeletoTabList extends StatelessWidget {
  const SeletoTabList({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.only(bottom: 24), children: children);
}

class SeletoAsyncError extends StatelessWidget {
  const SeletoAsyncError({
    super.key,
    this.message = 'Não foi possível carregar os dados.',
  });
  final String message;
  @override
  Widget build(BuildContext context) => SeletoEmptyState(
    icon: Icons.error_outline,
    title: 'Algo deu errado',
    message: message,
  );
}

String friendlyError(Object error) => error
    .toString()
    .replaceFirst('Bad state: ', '')
    .replaceFirst('Invalid argument(s): ', '')
    .replaceFirst('Invalid argument: ', '')
    .replaceFirst('FormatException: ', '');

Future<void> showOperationError(BuildContext context, Object error) async {
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
}

Future<DateTime?> pickSeletoDate(
  BuildContext context,
  DateTime initial, {
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final first = firstDate ?? DateTime(2010);
  final last = lastDate ?? DateTime(2100);
  final selected = initial.isBefore(first)
      ? first
      : initial.isAfter(last)
      ? last
      : initial;
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  return showDatePicker(
    context: context,
    initialDate: selected,
    firstDate: first,
    lastDate: last,
    locale: const Locale('pt', 'BR'),
    builder: (context, child) => Theme(
      data: theme.copyWith(
        dialogTheme: DialogThemeData(
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
          headerBackgroundColor: scheme.primary,
          headerForegroundColor: scheme.onPrimary,
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return scheme.onPrimary;
            if (states.contains(WidgetState.disabled)) {
              return scheme.onSurface.withValues(alpha: .38);
            }
            return scheme.onSurface;
          }),
          dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return scheme.primary;
            return Colors.transparent;
          }),
          todayForegroundColor: WidgetStateProperty.all(scheme.primary),
          todayBorder: BorderSide(color: scheme.primary),
          yearForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return scheme.onPrimary;
            return scheme.onSurface;
          }),
          yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return scheme.primary;
            return Colors.transparent;
          }),
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    ),
  );
}
