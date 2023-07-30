
import 'dart:io';

import 'package:flutter/material.dart';

class ImageView extends StatelessWidget
{
  final String path;
  ImageView(this.path);


  @override
  Widget build(BuildContext context)
  {
    return SafeArea(

      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Center(child: Image.file(File(path))),
            Positioned(top: 0,right: 0,child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.red,
                shape: const CircleBorder(),
              ),
                onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),),

          ],
        ),
      ),
    );
  }
}
