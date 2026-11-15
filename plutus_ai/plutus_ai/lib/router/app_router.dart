import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../core/widgets/shell_scaffold.dart';
import '../features/ai_assistant/screens/ai_assistant_screen.dart';
import '../features/alerts/screens/alerts_screen.dart';
import '../features/behavioural_finance/screens/behavioural_finance_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/markets/screens/markets_screen.dart';
import '../features/portfolio/screens/portfolio_screen.dart';
import '../features/research/screens/research_screen.dart';
import '../features/risk_intelligence/screens/risk_intelligence_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/watchlists/screens/watchlists_screen.dart';
import '../features/wealth_optimisation/screens/wealth_optimisation_screen.dart';

class _AuthRouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRefresh = _AuthRouterRefresh();
  ref.listen<AuthState>(authStateProvider, (previous, next) {
    authRefresh.refresh();
  });

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final path = state.uri.path;
      final isAuthRoute = path == '/login' || path == '/register';

      // Wait until the persisted session has been checked before redirecting.
      if (auth.isLoading) return null;
      if (!auth.isAuthenticated && !isAuthRoute) return '/login';
      if (auth.isAuthenticated && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(path: '/', name: 'overview', pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen())),
          GoRoute(path: '/markets', name: 'markets', pageBuilder: (context, state) => const NoTransitionPage(child: MarketsScreen())),
          GoRoute(path: '/portfolio', name: 'portfolio', pageBuilder: (context, state) => const NoTransitionPage(child: PortfolioScreen())),
          GoRoute(path: '/watchlists', name: 'watchlists', pageBuilder: (context, state) => const NoTransitionPage(child: WatchlistsScreen())),
          GoRoute(path: '/ai', name: 'assistant', pageBuilder: (context, state) => const NoTransitionPage(child: AiAssistantScreen())),
          GoRoute(path: '/behaviour', name: 'behaviour', pageBuilder: (context, state) => const NoTransitionPage(child: BehaviouralFinanceScreen())),
          GoRoute(path: '/risk', name: 'risk', pageBuilder: (context, state) => const NoTransitionPage(child: RiskIntelligenceScreen())),
          GoRoute(path: '/wealth', name: 'wealth', pageBuilder: (context, state) => const NoTransitionPage(child: WealthOptimisationScreen())),
          GoRoute(path: '/research', name: 'research', pageBuilder: (context, state) => const NoTransitionPage(child: ResearchScreen())),
          GoRoute(path: '/alerts', name: 'alerts', pageBuilder: (context, state) => const NoTransitionPage(child: AlertsScreen())),
          GoRoute(path: '/settings', name: 'settings', pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen())),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    authRefresh.dispose();
  });
  return router;
});
