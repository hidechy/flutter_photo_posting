import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:minio_new/minio.dart';

import '../../extensions/extensions.dart';
import '../../state/app_param/app_param_notifier.dart';

// ignore: must_be_immutable
class PhotoListAlert extends ConsumerWidget {
  PhotoListAlert({super.key});

  final minio = Minio(
    endPoint: 's3-ap-northeast-1.amazonaws.com',
    region: 'ap-northeast-1',
    accessKey: 'AKIA34XYAHBV2VZORD5Q',
    secretKey: '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',
  );

  late WidgetRef _ref;

  ///
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _ref = ref;

    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(width: context.screenSize.width),
                _displayUploadPhoto(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _displayUploadPhoto() {
    final list = <Widget>[];

    _ref.watch(appParamProvider.select((value) => value.imagePaths)).forEach((element) {
      list.add(Column(
        children: [
          Text(element),
          FutureBuilder(
            future: getImage(imagePath: element),
            builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
              if (snapshot.hasData) {
                return Center(child: snapshot.data);
              } else {
                return const Center(child: Text('データが取得できていません'));
              }
            },
          ),
          SizedBox(height: 30),
        ],
      ));
    });

    return SingleChildScrollView(child: Column(children: list));
  }

  ///
  Future<Image> getImage({required String imagePath}) async {
    final stream = await minio.getObject('s3test20230128toyoda', imagePath);

    final memory = <int>[];

    // ignore: prefer_foreach
    await for (final value in stream) {
      memory.addAll(value);
    }

    return Image.memory(Uint8List.fromList(memory));
  }
}
