import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:popbom/app/asset_paths.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key ,this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AssetPaths.appLogoSvg,
      width: width??265,
      height: height,
      fit: BoxFit.scaleDown,
    );

  }
}



class PopBomLogo extends StatelessWidget {
  const PopBomLogo({super.key ,this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AssetPaths.appLogoPopBomSvg,
      width: width??265,
      height: height,
      fit: BoxFit.scaleDown,
    );

  }
}

