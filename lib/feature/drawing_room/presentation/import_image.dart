
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'drawing_room_screen.dart';

class ImportImage extends StatelessWidget
{
  const ImportImage({super.key});



  Future<List<String>> pickImages({bool allowMultiple = true, List<String> extensions = const []}) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg',...extensions],
    );

    if (result != null) {
      return result.paths.whereType<String>().toList();
    }
    return [];
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      body: Center(child: ElevatedButton(
        onPressed: ()
        async
        {

          final images = await pickImages(allowMultiple: false);
          if (images.isNotEmpty)
          {
            Navigator.push(context, MaterialPageRoute(builder: (_)=> DrawingRoomScreen(backImage: images.first,)));
          }
        },child: const Text("Import Image"),),),
    );
  }

}