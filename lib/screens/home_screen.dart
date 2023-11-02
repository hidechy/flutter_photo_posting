import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../extensions/extensions.dart';
import '../state/app_param/app_param_notifier.dart';

// ignore: must_be_immutable
class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key, required this.innerCamera});

  final CameraDescription innerCamera;

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  ///
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _controller = CameraController(innerCamera, ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();

    final imagePath = ref.watch(appParamProvider.select((value) => value.imagePath));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: context.screenSize.width,
              height: context.screenSize.height * 0.7,
              child: (imagePath != '')
                  ? Image.file(File(imagePath))
                  : FutureBuilder<void>(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CameraPreview(_controller);
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
            ),
            Expanded(
              child: Container(
                width: context.screenSize.width,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final image = await _controller.takePicture();

                        await ref.read(appParamProvider.notifier).setImagePath(imagePath: image.path);
                      },
                      child: const Text('Shoot'),
                    ),
                    IconButton(
                      onPressed: () async {
                        await ref.read(appParamProvider.notifier).setImagePath(imagePath: '');

                        await Future.delayed(const Duration(milliseconds: 500));

                        if (context.mounted) {
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(innerCamera: innerCamera),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
