import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;

Future<ui.Image> getImage(String path) async {
  Completer<ImageInfo> completer = Completer();
  var netImg = new NetworkImage(path);
  netImg
      .resolve(ImageConfiguration())
      .addListener(ImageStreamListener((ImageInfo info, bool _) {
    completer.complete(info);
  }));
  ImageInfo imageInfo = await completer.future;
  ui.Image img = imageInfo.image;
  int height = 30;
  int width = height * (img.width / img.height).floor();
  return await resize(img, height, width);
}

Future<ui.Image> resize(ui.Image input, int height, int width) async {
  final ByteData assetImageByteData = await input.toByteData();
  // image.Image baseSizeImage =
  //     image.decodeImage(assetImageByteData.buffer.asUint8List());
  image.Image baseSizeImage = image.Image.fromBytes(
      input.width, input.height, assetImageByteData.buffer.asUint8List(),);
  image.Image resizeImage =
      image.copyResize(baseSizeImage, height: height, width: width,interpolation: image.Interpolation.average);
  ui.Codec codec =
      await ui.instantiateImageCodec(image.encodePng(resizeImage));
  ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}
