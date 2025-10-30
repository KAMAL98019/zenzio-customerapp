import 'package:flutter/material.dart';

class CompanyLogoLoadState extends StatelessWidget {
  const CompanyLogoLoadState({super.key});

  Widget loadImage({double width = 270, double height = 170}) {
    return Image.asset(
      'assets/images/mainlogo.png',
      width: width,
      height: height,
      cacheWidth: 270,
      cacheHeight: 130,
    );
  }

  @override
  Widget build(BuildContext context) {
    return loadImage();
  }
}
