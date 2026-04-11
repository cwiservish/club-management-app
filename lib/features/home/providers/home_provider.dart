import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_data.dart';
import '../services/home_service.dart';

final homeServiceProvider = Provider<HomeService>((ref) => HomeService());

final homeProvider = FutureProvider<HomeData>((ref) async {
  return ref.read(homeServiceProvider).getHomeData();
});
