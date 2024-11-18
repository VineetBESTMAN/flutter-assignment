import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:task_manager/core/di/injection. Continuing directly from the previous file content:

<boltAction type="file" filePath="lib/core/di/injection.dart">import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:task_manager/core/di/injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();