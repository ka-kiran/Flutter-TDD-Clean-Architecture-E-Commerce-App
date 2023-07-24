import 'package:auto_route/auto_route.dart';

import '../../presentation/views/main/main_view.dart';

part 'app_router.gr.dart';

//Run after change - dart run build_runner build --delete-conflicting-outputs
@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: MainViewRoute.page, initial: true),
  ];
}

final appRouter = AppRouter();