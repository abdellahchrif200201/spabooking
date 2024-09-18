import 'dart:io';
import 'dart:typed_data'; // Import Uint8List
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CompressedImage extends StatefulWidget {
  final String imageUrl;

  const CompressedImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _CompressedImageState createState() => _CompressedImageState();
}

class _CompressedImageState extends State<CompressedImage> {
  late File _compressedImage;

  @override
  void initState() {
    super.initState();
    _compressImage();
  }

  Future<void> _compressImage() async {
    try {
      // Download the image from the URL
      http.Response response = await http.get(Uri.parse(widget.imageUrl));
      Uint8List imageData =
          response.bodyBytes as Uint8List; // Convert to Uint8List

      // Compress the image
      List<int> compressedImageData =
          await FlutterImageCompress.compressWithList(
        imageData,
        quality: 50, // Adjust the quality as needed (0-100)
      );

      // Get the temporary directory
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      // Write the compressed image to a file
      File compressedImageFile = File('$tempPath/compressed_image.jpg');
      await compressedImageFile.writeAsBytes(compressedImageData);

      setState(() {
        _compressedImage = compressedImageFile;
      });
    } catch (e) {
      print('Error compressing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compressed Image'),
      ),
      body: Center(
        child: _compressedImage != null
            ? Image.file(_compressedImage)
            : CircularProgressIndicator(),
      ),
    );
  }
}

class CompressedImageBackgroundContainer extends StatefulWidget {
  final String imageUrl;
  final Widget child;

  const CompressedImageBackgroundContainer({
    Key? key,
    required this.imageUrl,
    required this.child,
  }) : super(key: key);

  @override
  _CompressedImageBackgroundContainerState createState() =>
      _CompressedImageBackgroundContainerState();
}

class _CompressedImageBackgroundContainerState
    extends State<CompressedImageBackgroundContainer> {
  File? _compressedImage; // Initialize as null

  @override
  void initState() {
    super.initState();
    _compressImage();
  }

  Future<void> _compressImage() async {
    print(widget.imageUrl);
    try {
      // Download the image from the URL
      http.Response response = await http.get(Uri.parse(widget.imageUrl));
      Uint8List imageData =
          response.bodyBytes as Uint8List; // Convert to Uint8List

      // Compress the image
      List<int> compressedImageData =
          await FlutterImageCompress.compressWithList(
        imageData,
        quality: 50, // Adjust the quality as needed (0-100)
      );

      // Get the temporary directory
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      // Write the compressed image to a file
      File compressedImageFile = File('$tempPath/compressed_image.jpg');
      await compressedImageFile.writeAsBytes(compressedImageData);

      setState(() {
        _compressedImage = compressedImageFile;
      });
    } catch (e) {
      print('Error compressing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _compressedImage != null
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
              image: DecorationImage(
                image: FileImage(_compressedImage!),
                fit: BoxFit.cover,
              ),
            ),
            child: widget.child,
          )
        : Container(); // Return an empty container while the image is loading
  }
}

// Example usage


