import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/seleto_theme.dart';

class SeletoApp extends ConsumerWidget {
  const SeletoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'GRANJA SELETO',
    debugShowCheckedModeBanner: false,
    theme: SeletoTheme.light,
    darkTheme: SeletoTheme.dark,
    routerConfig: ref.watch(routerProvider),
  );
}
