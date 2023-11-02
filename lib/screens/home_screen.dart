import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:minio_new/minio.dart';

import '../extensions/extensions.dart';
import '../state/app_param/app_param_notifier.dart';
import 'alert/_photo_dialog.dart';
import 'alert/photo_list_alert.dart';

// ignore: must_be_immutable
class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  final minio = Minio(
    endPoint: 's3-ap-northeast-1.amazonaws.com',
    region: 'ap-northeast-1',
    accessKey: 'AKIA34XYAHBV2VZORD5Q',
    secretKey: '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',
  );

  ///
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _controller = CameraController(cameras[1], ResolutionPreset.medium); // 0:外カメ　1:内カメ

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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final image = await _controller.takePicture();

                            final fileExtension = image.path.substring(image.path.lastIndexOf('.'));

                            final newFileName = '${DateTime.now().yyyymmdd}/${DateTime.now()}$fileExtension';

                            final imageFile = File(image.path);
                            final imageRaw = await imageFile.readAsBytes();

                            await minio.putObject('s3test20230128toyoda', newFileName, Stream.value(imageRaw));

                            await ref.read(appParamProvider.notifier).setImagePath(imagePath: image.path);

                            await ref.read(appParamProvider.notifier).setImagePaths(imagePath: newFileName);
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
                                MaterialPageRoute(builder: (context) => HomeScreen(cameras: cameras)),
                              );
                            }
                          },
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            PhotoDialog(
                              context: context,
                              widget: PhotoListAlert(),
                            );
                          },
                          icon: const Icon(Icons.ac_unit),
                        ),
                        Container(),
                      ],
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
