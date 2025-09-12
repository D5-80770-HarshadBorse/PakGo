import 'package:get_it/get_it.dart';
import 'package:pakgo/core/utils/navigation_service.dart';

// Create a GetIt instance
final GetIt locator = GetIt.instance;

// Setup function to register services
void setupLocator() {
  // Register NavigationService as a lazy singleton.
  // It will be created only when it's first used.
  locator.registerLazySingleton(() => NavigationService());
}
