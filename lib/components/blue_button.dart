import 'package:flutter/material.dart';

import '../constant.dart';

class BlueButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  final padding;
  const BlueButton({Key key, this.label, this.onPressed, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          EdgeInsets.zero,
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
          Colors.transparent,
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              5.0,
            ),
          ),
        ),
        // side: MaterialStateProperty.all<BorderSide>(
        //   BorderSide(
        //     color: Colors.blue[900],
        //     width: 1.0,
        //   ),
        // ),
      ),
      onPressed: onPressed,
      child: Container(
        padding: padding ??
            EdgeInsets.symmetric(
              vertical: 10.0,
            ),
        decoration: BoxDecoration(
          gradient: kGradient,
          borderRadius: BorderRadius.all(
            Radius.circular(
              5.0,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
