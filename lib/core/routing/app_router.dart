import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/egg_collection/presentation/pages/egg_collection_page.dart';
import '../../features/lots/presentation/pages/lots_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../../features/operations/presentation/pages/audit_page.dart';
import '../../features/operations/presentation/pages/alerts_page.dart';
import '../../features/operations/presentation/pages/calendar_page.dart';
import '../../features/operations/presentation/pages/commercial_page.dart';
import '../../features/operations/presentation/pages/egg_stock_page.dart';
import '../../features/operations/presentation/pages/feed_page.dart';
import '../../features/operations/presentation/pages/finance_page.dart';
import '../../features/operations/presentation/pages/movements_page.dart';
import '../../features/operations/presentation/pages/reports_page.dart';
import '../../features/operations/presentation/pages/settings_page.dart';
import '../widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final atLogin = state.uri.path == '/login';
      if (!auth.isAuthenticated) {
        return atLogin ? null : '/login';
      }
      if (atLogin) {
        return '/dashboard';
      }
      final destination = seletoDestinations
          .where((d) => d.route == state.uri.path)
          .firstOrNull;
      if (destination != null && !auth.allows(destination.permission)) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/dashboard', builder: (_, _) => const DashboardPage()),
      GoRoute(path: '/lots', builder: (_, _) => const LotsPage()),
      GoRoute(
        path: '/egg-collection',
        builder: (_, _) => const EggCollectionPage(),
      ),
      GoRoute(path: '/users', builder: (_, _) => const UsersPage()),
      GoRoute(path: '/movements', builder: (_, _) => const MovementsPage()),
      GoRoute(path: '/feed', builder: (_, _) => const FeedPage()),
      GoRoute(path: '/egg-stock', builder: (_, _) => const EggStockPage()),
      GoRoute(path: '/commercial', builder: (_, _) => const CommercialPage()),
      GoRoute(path: '/finance', builder: (_, _) => const FinancePage()),
      GoRoute(path: '/calendar', builder: (_, _) => const CalendarPage()),
      GoRoute(path: '/reports', builder: (_, _) => const ReportsPage()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
      GoRoute(path: '/audit', builder: (_, _) => const AuditPage()),
      GoRoute(path: '/alerts', builder: (_, _) => const AlertsPage()),
    ],
  );
});
