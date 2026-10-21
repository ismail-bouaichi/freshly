import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/routes.dart';
import 'core/theme.dart';
import 'data/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarColor: AppColors.cream),
  );
  runApp(FreshlyApp(state: AppState()));
}

class FreshlyApp extends StatelessWidget {
  const FreshlyApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Freshly',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        initialRoute: Routes.onboarding,
        onGenerateRoute: onGenerateRoute,
        builder: (context, child) {
          // Keep layouts close to the 390-pt design on very large text settings.
          final mq = MediaQuery.of(context);
          final scale = mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.25);
          return MediaQuery(
            data: mq.copyWith(textScaler: scale),
            child: child!,
          );
        },
      ),
    );
  }
}
