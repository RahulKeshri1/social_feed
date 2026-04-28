import 'package:flutter/widgets.dart';

abstract final class ImageUtils {
  static int getCacheWidth(BuildContext context, {double? displayWidth}) {
    final mq = MediaQuery.of(context);
    final w = displayWidth ?? mq.size.width;
    final dpr = mq.devicePixelRatio;
    return (w * dpr).toInt();
  }

  static int getCacheHeight(BuildContext context, {required double displayHeight}) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return (displayHeight * dpr).toInt();
  }
}
