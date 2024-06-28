import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.cameras});
  final List<CameraDescription> cameras;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.max,
        enableAudio: false);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.takePicture().then((XFile file) async {
            final image = await img.decodeImageFile(file.path);
            if (image == null) {
              if (!context.mounted) {
                return;
              }
              return Navigator.pop(context, null);
            }
            // 正方形に切り抜いて 500x500 にリサイズ
            final cmd = img.Command()
              ..image(image)
              ..copyCrop(x: 0, y: 0, width: image.width, height: image.width)
              ..copyResize(width: 500, height: 500);
            final image2 = await cmd.getImageThread();
            if (context.mounted) Navigator.pop(context, image2);
          });
        },
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: ClipRRect(
          child: SizedOverflowBox(
            alignment: Alignment.topLeft,
            size: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.width),
            child: CameraPreview(
              controller,
            ),
          ),
        ),
      ),
    );
  }
}
