import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app_param_state.dart';

////////////////////////////////////////////////
final appParamProvider = StateNotifierProvider.autoDispose<AppParamNotifier, AppParamState>((ref) {
  return AppParamNotifier(const AppParamState());
});

class AppParamNotifier extends StateNotifier<AppParamState> {
  AppParamNotifier(super.state);

  ///
  Future<void> setImagePath({required String imagePath}) async => state = state.copyWith(imagePath: imagePath);

  ///
  Future<void> setImagePaths({required String imagePath}) async {
    final imagePaths = [...state.imagePaths, imagePath];

    state = state.copyWith(imagePaths: imagePaths);
  }
}

////////////////////////////////////////////////
