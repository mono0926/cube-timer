import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/history/presentation/history_page.dart';
import '../../features/timer/presentation/timer_page.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    routes: $appRoutes,
    initialLocation: '/',
  );
}

@TypedGoRoute<TimerRoute>(
  path: '/',
  routes: [
    TypedGoRoute<HistoryRoute>(
      path: 'history',
    ),
  ],
)
class TimerRoute extends GoRouteData with _$TimerRoute {
  const TimerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const TimerPage();
}

class HistoryRoute extends GoRouteData with _$HistoryRoute {
  const HistoryRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const HistoryPage();
}
