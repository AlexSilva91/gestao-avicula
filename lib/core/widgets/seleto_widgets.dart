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
        spacing: 12,
        runSpacing: 8,
        children: [
          SizedBox(
            width: textWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 12), action!],
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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accent, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: columns == 1 ? 4.2 : 2.35,
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
      ListView(padding: const EdgeInsets.only(bottom: 16), children: children);
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

Future<String?> pickSeletoTime(BuildContext context, String current) async {
  final parts = current.split(':');
  final hour = int.tryParse(parts.first);
  final minute = int.tryParse(parts.elementAtOrNull(1) ?? '');
  final initial = TimeOfDay(
    hour: hour != null && hour >= 0 && hour <= 23 ? hour : 8,
    minute: minute != null && minute >= 0 && minute <= 59 ? minute : 0,
  );
  final picked = await showTimePicker(
    context: context,
    initialTime: initial,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child ?? const SizedBox.shrink(),
    ),
  );
  if (picked == null) return null;
  final formattedHour = picked.hour.toString().padLeft(2, '0');
  final formattedMinute = picked.minute.toString().padLeft(2, '0');
  return '$formattedHour:$formattedMinute';
}

String defaultSeletoAlertTime(DateTime date, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  if (!_sameDay(date, reference)) return '08:00';
  final next = reference.add(const Duration(minutes: 10));
  if (!_sameDay(date, next)) return '23:59';
  final hour = next.hour.toString().padLeft(2, '0');
  final minute = next.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

bool seletoAlertTimeIsPast(DateTime date, String time, {DateTime? now}) {
  final parts = time.split(':');
  final hour = int.tryParse(parts.first) ?? 8;
  final minute = int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0;
  final alertAt = DateTime(date.year, date.month, date.day, hour, minute);
  return !alertAt.isAfter(now ?? DateTime.now());
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
