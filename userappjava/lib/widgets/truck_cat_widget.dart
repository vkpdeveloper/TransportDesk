import 'package:flutter/material.dart';

class TruckCategory extends StatelessWidget {
  final VoidCallback onTap;
  final Widget text;
  final Color borderColor;
  final BuildContext btnContext;
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;
  const TruckCategory(
      {Key key,
      @required this.onTap,
      @required this.text,
      @required this.borderColor,
      @required this.btnContext,
      @required this.backgroundColor,
      @required this.foregroundColor,
      this.elevation})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: elevation ?? 8.0,
      color: backgroundColor,
      textColor: foregroundColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: borderColor, width: 3)),
      height: 40.0,
      minWidth: (MediaQuery.of(btnContext).size.width / 2) - 40,
      child: text,
      onPressed: onTap,
    );
  }
}
