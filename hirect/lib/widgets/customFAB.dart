import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  final name;
  final func;
  final icon;
  const CustomFAB(this.func, this.icon, this.name);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        func();
      },
      label: Text(name),
      icon: Icon(icon),
      backgroundColor: Colors.green,
    );
  }
}
