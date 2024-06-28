import 'dart:convert';
import 'dart:ui' as ui;

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

const graphQLDocument = '''
  query calorieCalculation(\$base64String: String!) {
    calorieCalculation(base64String: \$base64String) 
  }
''';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  img.Image? _image;
  Map<String, dynamic>? _response;
  bool _isLoading = false;

  // 画像ファイルを表示するための関数
  // https://github.com/brendan-duncan/image/blob/9edfa0e54d70d8c03effe61b18bdd70ff01ccf7b/doc/flutter.md#convert-a-dart-image-library-image-to-a-flutter-ui-image
  Future<ui.Image> convertImageToFlutterUi(img.Image image) async {
    if (image.format != img.Format.uint8 || image.numChannels != 4) {
      final cmd = img.Command()
        ..image(image)
        ..convert(format: img.Format.uint8, numChannels: 4);
      final rgba8 = await cmd.getImageThread();
      if (rgba8 != null) {
        image = rgba8;
      }
    }

    ui.ImmutableBuffer buffer =
        await ui.ImmutableBuffer.fromUint8List(image.toUint8List());

    ui.ImageDescriptor id = ui.ImageDescriptor.raw(buffer,
        height: image.height,
        width: image.width,
        pixelFormat: ui.PixelFormat.rgba8888);

    ui.Codec codec = await id.instantiateCodec(
        targetHeight: image.height, targetWidth: image.width);

    ui.FrameInfo fi = await codec.getNextFrame();
    ui.Image uiImage = fi.image;

    return uiImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            _image = await Navigator.pushNamed(context, "/camera") as img.Image;
            setState(() {
              _response = null;
            });
          },
          label: const Icon(Icons.camera_alt)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _image != null
                  ? FutureBuilder(
                      future: convertImageToFlutterUi(_image!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        return RawImage(image: snapshot.data as ui.Image);
                      })
                  : const Center(
                      child: Text("写真を撮ってカロリーを計算する",
                          style: TextStyle(fontSize: 20))),
              const SizedBox(
                height: 20,
              ),
              if (_image != null)
                ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      // jpg形式でbase64エンコード
                      final base64String = base64Encode(img.encodeJpg(_image!));
                      final request = GraphQLRequest<String>(
                          document: graphQLDocument,
                          variables: <String, String>{
                            "base64String": base64String
                          },
                          authorizationMode: APIAuthorizationType.apiKey);

                      final response =
                          await Amplify.API.query(request: request).response;
                      Map<String, dynamic> jsonMap =
                          json.decode(response.data!);

                      setState(() {
                        _isLoading = false;
                        _response = json.decode(jsonMap["calorieCalculation"]);
                      });
                    },
                    child: const Text('Upload')),
              if (_isLoading) const CircularProgressIndicator(),
              if (_response != null)
                Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    Text(
                      "${_response!["food"]}",
                      style: const TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      "${_response!["calorie"]} kcal",
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
