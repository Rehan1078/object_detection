import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tflite/tflite.dart';

import 'main.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  CameraImage? cameraImage; // Nullable for null safety
  CameraController? cameraController; // Nullable for null safety
  bool isWorking = false; // Use camel case for variable names
  String result = "No results yet";

  @override
  void initState() {
    super.initState();
    // loadModel().then((_) {
    //   initCamera();
    // });
    loadModel();
  }


  // Initialize the camera
  void initCamera() async {
    try {
      cameraController = CameraController(cameraas[0], ResolutionPreset.medium);
      await cameraController?.initialize();
      if (!mounted) return;

      setState(() {
        Fluttertoast.showToast(msg: "Camera initialized successfully");
      });

      cameraController?.startImageStream((imageFromStream) {
        if (!isWorking) {
          isWorking = true;
          cameraImage = imageFromStream;

          Fluttertoast.showToast(msg: "Image stream started");
          processImage();
        }
      });
    } catch (e) {
      print("Error initializing camera: $e");
      Fluttertoast.showToast(msg: "Error initializing camera: $e");
    }
  }

  // Process the image from the camera and run the TFLite model
  void processImage() async {
    final cameraImage = this.cameraImage;
    if (cameraImage != null) {
      Fluttertoast.showToast(msg: "Processing image");

      var recognition = await Tflite.runModelOnFrame(
        bytesList: cameraImage.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );

      if (recognition == null) {
        Fluttertoast.showToast(msg: "No recognition results");
      } else {
        Fluttertoast.showToast(msg: "Recognition completed");
      }

      setState(() {
        result = "";
        recognition?.forEach((response) {
          result += response["label"] +
              " " +
              (response["confidence"] as double).toStringAsFixed(2) +
              "\n\n";
        });
      });

      isWorking = false;
    } else {
      Fluttertoast.showToast(msg: "No camera image available");
    }
  }

  // Dispose of the camera controller when not needed
  @override
  void dispose() async{
    cameraController?.dispose();
    // await Tflite?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detection'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                height: 400,
                width:700,
                child: cameraController == null
                    ? Center(child: CircularProgressIndicator())
                    : AspectRatio(
                  aspectRatio: cameraController!.value.aspectRatio,
                  child: CameraPreview(cameraController!),
                ),
              ),

            ],
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Text(
              result,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model/mobilenet_v1_1.0_224.tflite",
        labels: "assets/model/mobilenet_v1_1.0_224.txt",
      );
      Fluttertoast.showToast(msg: "Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
      Fluttertoast.showToast(msg: "Error loading model: $e");
    }
  }

}
