import 'package:flutter/material.dart';

class BoxTile extends StatelessWidget {
  final Widget child;
  final Function onPressed;
  final bool selected;
  final Color color;
  final Size size;
  BoxTile({
    @required this.child,
    @required this.onPressed,
    this.selected = false,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              10.0,
            ),
          ),
          side: selected
              ? BorderSide(
                  color: Colors.white38,
                  width: 5,
                )
              : BorderSide(
                  color: Colors.transparent,
                  width: 5,
                ),
        ),
        child: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            // gradient: kGradient,
            color: color,
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}
