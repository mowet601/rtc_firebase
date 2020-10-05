import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';

class Utils {
  static String getUsername(String email) {
    return 'stelvid:${email.split('@')[0]}';
  }

  static void makeToast(String messageStr, Color color) {
    Fluttertoast.showToast(
        msg: messageStr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static Future<File> pickImage(ImageSource source) async {
    final ImagePicker ip = ImagePicker();
    PickedFile selectedImage = await ip.getImage(source: source);
    File file = File(selectedImage.path);
    return compressImage(file);
  }

  static Future<File> compressImage(File image2compress) async {
    final tempdir = await getTemporaryDirectory();
    final path = tempdir.path;
    int random = Random().nextInt(1000);
    Im.Image image = Im.decodeImage(image2compress.readAsBytesSync());
    image = Im.copyResize(image, width: 500, height: 500);
    return new File('$path/img_$random.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));
  }
}

// class UniversalColors {
//   static final Color lightBlueColor = Color(0xff0077d7);
//   static final Color separatorColor = Color(0xff272c35);

//   static final Color gradientStartColor = Colors.teal;
//   static final Color gradientEndColor = Colors.blueAccent;

//   static final Color senderColor = Color(0xff2b343b);
//   static final Color receiverColor = Color(0xff1e2225);

//   static final Gradient fabGradient = LinearGradient(
//       colors: [gradientStartColor, gradientEndColor],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight);
// }

enum ViewState { LOADING, IDLE }

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final bool isRound;
  final double radius;
  final double height;
  final double width;
  final BoxFit fit;
  final String noImgAvailable = 'https://via.placeholder.com/150';

  CachedImage(
    this.imageUrl, {
    this.isRound = false,
    this.radius = 0,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return SizedBox(
        height: isRound ? radius : height,
        width: isRound ? radius : width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isRound ? 50 : radius),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: fit,
            placeholder: (c, u) => Center(child: CircularProgressIndicator()),
            errorWidget: (c, u, e) =>
                Image.network(noImgAvailable, fit: BoxFit.cover),
          ),
        ),
      );
    } catch (e) {
      print(e);
      return Image.network(noImgAvailable, fit: BoxFit.cover);
    }
  }
}
// class ImageUploadProvider with ChangeNotifier {
//   ViewState _viewState = ViewState.IDLE;
//   ViewState get getViewState => _viewState;

//   void setToLoading() {
//     _viewState = ViewState.LOADING;
//     notifyListeners();
//   }

//   void setToidle() {
//     _viewState = ViewState.IDLE;
//     notifyListeners();
//   }
// }
