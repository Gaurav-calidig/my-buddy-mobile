import 'package:flutter/cupertino.dart';

/// Creates vertical spacing between widgets.
///
/// [height] The height of the spacing in logical pixels.
/// [width] Optional width constraint for the spacing widget.
Widget verticalSpace(double height, {double? width}) => SizedBox(height: height, width: width);

/// Creates horizontal spacing between widgets.
///
/// [width] The width of the spacing in logical pixels.
/// [height] Optional height constraint for the spacing widget.
Widget horizontalSpace(double width, {double? height}) => SizedBox(height: height, width: width);