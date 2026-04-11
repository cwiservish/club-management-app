import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/registration_item.dart';
import '../services/registration_service.dart';

final registrationServiceProvider = Provider<RegistrationService>((ref) => RegistrationService());

final registrationProvider = FutureProvider<List<RegistrationItem>>((ref) async {
  return ref.read(registrationServiceProvider).getItems();
});
