import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    routerConfig: ref.watch(routerProvider),
  );
}
