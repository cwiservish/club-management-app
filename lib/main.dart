import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/environment_config.dart';
import 'core/common_providers/current_user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvironmentConfig.load();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final container = ProviderContainer();
  // Eagerly initialize providers that the router depends on
  await container.read(currentUserProvider.future);

  runApp(UncontrolledProviderScope(
    container: container,
    child: const Playbook365App(),
  ));
}
