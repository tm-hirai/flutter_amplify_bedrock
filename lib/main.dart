import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amplify_bedrock/amplifyconfiguration.dart';
import 'package:flutter_amplify_bedrock/camera_screen.dart';
import 'package:flutter_amplify_bedrock/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await _configureAmplify();

    await Permission.camera.request();
    final cameras = await availableCameras();
    runApp(MyApp(
      cameras: cameras,
    ));
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAPI());
    await Amplify.configure(amplifyConfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: "/",
      routes: {
        '/': (context) => const HomeScreen(),
        "/camera": (context) => CameraScreen(cameras: cameras),
      },
    );
  }
}
