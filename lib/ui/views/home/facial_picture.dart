import 'dart:io';

import 'package:fh2019/core/config/routes.dart';
import 'package:fh2019/core/models/category.dart';
import 'package:fh2019/core/models/item.dart';
import 'package:fh2019/core/shared/custom_colors.dart';
import 'package:fh2019/core/viewmodel/item_viewmodel.dart';
import 'package:fh2019/ui/views/home/facial_order.dart';
import 'package:fh2019/ui/widgets/carousel_banner.dart';
import 'package:fh2019/ui/widgets/footer_button.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'face_painter.dart';
import 'dart:ui' as ui;

class FacialPicture extends StatefulWidget {
  FacialPicture({Key key}) : super(key: key);
  _FacialPictureState createState() => _FacialPictureState();
}

class _FacialPictureState extends State<FacialPicture>
    with AutomaticKeepAliveClientMixin<FacialPicture> {
  @override
  bool get wantKeepAlive => true;

  double _smilingProbability = 0;
  Emotion _emotion = Emotion.NORMAL;
  Color _color;

  File _imageFile;
  List<Face> _faces;
  bool isLoading = false;
  ui.Image _image;

  @override
  void initState() {
    super.initState();
  }

  _getImageAndDetectFaces({bool isCamera = true}) async {
    File imageFile;
    if (isCamera) {
      imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    } else {
      imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    }

    setState(() {
      isLoading = true;
    });

    if (imageFile == null) {
      setState(() => isLoading = false);
      print('end1');
      return;
    }
    print('end2');

//     FirebaseVisionFaceDetectorOptions highAccuracyOpts =
//         new FirebaseVisionFaceDetectorOptions.Builder()
//             .setPerformanceMode(FirebaseVisionFaceDetectorOptions.ACCURATE)
//             .setLandmarkMode(FirebaseVisionFaceDetectorOptions.ALL_LANDMARKS)
//             .setClassificationMode(
//                 FirebaseVisionFaceDetectorOptions.ALL_CLASSIFICATIONS)
//             .build();

// val highAccuracyOpts = FirebaseVisionFaceDetectorOptions.Builder()
//         .setPerformanceMode(FirebaseVisionFaceDetectorOptions.ACCURATE)
//         .setLandmarkMode(FirebaseVisionFaceDetectorOptions.ALL_LANDMARKS)
//         .setClassificationMode(FirebaseVisionFaceDetectorOptions.ALL_CLASSIFICATIONS)
//         .build()

    final image = FirebaseVisionImage.fromFile(imageFile);
    final faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> faces = await faceDetector.processImage(image);

    print('${faces.length}');
    print('EVER AFTER');

    for (var face in faces) {
      print(face.smilingProbability);

      // If classification was enabled with FaceDetectorOptions:
      if (face.smilingProbability != null) {
        _smilingProbability = face.smilingProbability;

        print(face.smilingProbability);
      }
    }

    if (mounted) {
      setState(() {
        _emotionEquivalent(_smilingProbability);
        _imageFile = imageFile;
        _faces = faces;
        _loadImage(imageFile);
      });
    }
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then(
      (value) => setState(() {
        _image = value;
        isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ItemViewModel itemViewModel = Provider.of<ItemViewModel>(context);

    return Scaffold(
        body: Column(
          children: <Widget>[
            CarouselBanner(),
            Expanded(
                child: Stack(
              children: <Widget>[
                Container(),
                Positioned(
                  right: 10,
                  bottom: 20,
                  child: MaterialButton(
                    padding: EdgeInsets.all(15),
                    shape: CircleBorder(),
                    color: CustomColors.green,
                    onPressed: () => _getImageAndDetectFaces(isCamera: false),
                    elevation: 2,
                    child: Icon(
                      Icons.image,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 90,
                  child: MaterialButton(
                    padding: EdgeInsets.all(15),
                    shape: CircleBorder(),
                    color: CustomColors.green,
                    onPressed: () => _getImageAndDetectFaces(isCamera: true),
                    elevation: 2,
                    child: Icon(
                      Icons.camera,
                      color: Colors.white,
                    ),
                  ),
                ),
                Align(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      isLoading
                          ? Center(child: CircularProgressIndicator())
                          : (_imageFile == null)
                              ? _buildNoImageSelected(context)
                              : SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.6,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        child: FittedBox(
                                          child: SizedBox(
                                            width: _image.width.toDouble(),
                                            height: _image.height.toDouble(),
                                            child: CustomPaint(
                                              painter:
                                                  FacePainter(_image, _faces),
                                            ),
                                          ),
                                        ),
                                      ),
                                      (_faces.length > 0)
                                          ? Text(
                                              "${_emotion.toString().split('.').last}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline
                                                  .copyWith(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            )
                                          : Container(),
                                      (_faces.length > 0)
                                          ? Text(
                                              "Smiling Probability: $_smilingProbability",
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body1
                                                  .copyWith(
                                                    color: Colors.black,
                                                  ),
                                            )
                                          : Container()
                                    ],
                                  ),
                                ),
                    ],
                  ),
                )),
              ],
            )),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: new FooterButton(
                      title: "Back",
                      color: CustomColors.red,
                      func: cancelOrder,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: new FooterButton(
                      color: CustomColors.blue,
                      title: "Next",
                      func:
                          (_imageFile != null) ? () => getFacialOrder() : null,
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  Column _buildNoImageSelected(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Text(
          "No Image Selected",
          style: Theme.of(context).textTheme.headline.copyWith(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          "Select image or capture a selfie",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.body1.copyWith(
                color: Colors.black,
              ),
        )
      ],
    );
  }

  void _emotionEquivalent(double smilingProbability) {
    if (smilingProbability >= 0.60) {
      _emotion = Emotion.HAPPY;
      _color = CustomColors.green;
    } else if (smilingProbability < 0.60 && smilingProbability >= 0.40) {
      _emotion = Emotion.NORMAL;
      _color = CustomColors.blue;
    } else {
      _emotion = Emotion.SAD;
      _color = CustomColors.red;
    }
  }

  void getFacialOrder() async {
    final ItemViewModel itemViewModel = Provider.of<ItemViewModel>(context);
    await itemViewModel.resetCartItemOrder();
    await itemViewModel.filterItem(Category.listCategory[0]);

    // Emotion emo = Emotion.SAD;
    // Emotion emo = Emotion.HAPPY;
    await itemViewModel.getFacialOrder(_emotion);
    // Navigator.of(context).pushNamed(Routes.facialorder, emotion: emo);

    Navigator.pushNamed(
      context,
      Routes.facialorder,
      arguments: FacialOrder(emotion: _emotion),
    );
  }

  cancelOrder() {
    Navigator.of(context).pop();
  }
}
