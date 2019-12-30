import 'package:fh2019/core/shared/custom_colors.dart';
import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final String title;
  final Function func;
  final bool active;

  CategoryButton({
    Key key,
    @required this.title,
    @required this.func,
    this.active = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
        shape: new RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey, width: 1),
            borderRadius: new BorderRadius.circular(20.0)),
        onPressed: func,
        color: active ? CustomColors.yellow : Colors.grey[200],
        child: Text(
          "${title.toString()}",
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
