import 'package:flutter/material.dart';

class InfoCard extends StatefulWidget {
  final String title;
  final Icon icon;
  final String description;
  final VoidCallback onTap;
  final double height;
  final double width;
  final BorderRadiusGeometry borderRadius;

  const InfoCard(
      {Key key,
      this.title,
      this.icon,
      this.description,
      this.onTap,
      this.borderRadius,
      this.height,
      this.width})
      : super(key: key);

  @override
  _InfoCardState createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  blurRadius: 14.0,
                  color: Colors.grey.shade100,
                  spreadRadius: 10)
            ]),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: Text(
                      widget.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  widget.icon
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  widget.description,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
