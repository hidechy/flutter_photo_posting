import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final innerCamera = cameras[1]; // 内カメをセット　※0:外カメ　1:内カメ
  runApp(ProviderScope(child: MyApp(innerCamera: innerCamera)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.innerCamera});

  final CameraDescription innerCamera;

  ///
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'photo posting',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: HomeScreen(innerCamera: innerCamera),
    );
  }
}
