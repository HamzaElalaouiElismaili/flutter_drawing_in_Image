import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:path_provider/path_provider.dart';
import '../model/drawing_point.dart';
import 'widgets/custom_paint.dart';
import 'widgets/image_view.dart';


class DrawingRoomScreen extends StatefulWidget {

  final String backImage;
  const DrawingRoomScreen({super.key,required this.backImage});

  @override
  State<DrawingRoomScreen> createState() => _DrawingRoomScreenState();
}

class _DrawingRoomScreenState extends State<DrawingRoomScreen> {
  var avaiableColor = [
    const Color(0xffED4C5C),
    const Color(0xffFFC553),
    const Color(0xff896BD8),
    const Color(0xffFF772B),
    const Color(0xff37B34A),
    const Color(0xff313131),
    const Color(0xffFFFFFF),
  ];

  var historyDrawingPoints = <DrawingPoint>[];
  var drawingPoints = <DrawingPoint>[];

  var selectedColor = const Color(0xff313131);
  var selectedWidth = 4.0;

  DrawingPoint? currentDrawingPoint;


  final _canvasKey = GlobalKey();

  Future<String> _saveCombinedImage() async {
    try {
      // Create an image from the drawing area
      RenderRepaintBoundary boundary = _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);


      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List drawingBytes = byteData!.buffer.asUint8List();

      final drawing = img.decodeImage(drawingBytes);

      // Load the background image
     final backgroundBytes = await File(widget.backImage).readAsBytes();

     //  Load the background image and the drawing image
     final background = img.decodeImage(backgroundBytes);

      // Draw the drawing on the background image
      var combinedImage = img.compositeImage(background!, drawing! );


      // Save the combined image to a file
      var appDocDir = await getTemporaryDirectory();

      String timeNow = DateTime.now().toIso8601String();

      final filePath = "${appDocDir.path}/${timeNow}_path.png";

      File(filePath).writeAsBytesSync(img.encodePng(combinedImage));

      return filePath;
    } catch (e) {
      print('Error saving image: $e');
      return "";
    }
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text("Drawing Room"),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [


          Image.file(File(widget.backImage)),

          RepaintBoundary(
           key: _canvasKey,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  currentDrawingPoint = DrawingPoint(
                    id: DateTime.now().microsecondsSinceEpoch,
                    offsets: [
                      details.localPosition,
                    ],
                    color: selectedColor,
                    width: selectedWidth,
                  );

                  if (currentDrawingPoint == null) return;
                  drawingPoints.add(currentDrawingPoint!);
                  historyDrawingPoints = List.of(drawingPoints);
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  if (currentDrawingPoint == null) return;

                  currentDrawingPoint = currentDrawingPoint?.copyWith(
                    offsets: currentDrawingPoint!.offsets
                      ..add(details.localPosition),
                  );
                  drawingPoints.last = currentDrawingPoint!;
                  historyDrawingPoints = List.of(drawingPoints);
                });
              },
              onPanEnd: (_) {
                currentDrawingPoint = null;
              },
              child: CustomPaint(
                painter: DrawingPainter(drawingPoints: drawingPoints,),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            right: 15,
            bottom: 150,
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height*0.5,
              width: 35,
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                itemCount: avaiableColor.length,
                separatorBuilder: (_, __) {
                  return const SizedBox(height: 8);
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = avaiableColor[index];
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: avaiableColor[index],
                        shape: BoxShape.circle,
                      ),
                      foregroundDecoration: BoxDecoration(
                        border: selectedColor == avaiableColor[index]
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),



        ],
      ),

      floatingActionButton: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "Undo",
          onPressed: () {

            if (drawingPoints.isNotEmpty && historyDrawingPoints.isNotEmpty) {
              setState(() {
                drawingPoints.removeLast();
              });
            }

          },
          child: const Icon(Icons.undo),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: "Redo",
          onPressed: () {
            setState(()
            {
              if (drawingPoints.length < historyDrawingPoints.length) {
                final index = drawingPoints.length;
                drawingPoints.add(historyDrawingPoints[index]);
              }
            });

          },
          child: const Icon(Icons.redo),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: "Save",
          onPressed: () async
          {
           final String _path = await   _saveCombinedImage();


           if(_path != "")
           {
             Navigator.push(context, MaterialPageRoute(builder: (_)=>ImageView(_path)));
           }
          },
          child: const Icon(Icons.save),
        ),
      ],
    ),

    );
  }
}




