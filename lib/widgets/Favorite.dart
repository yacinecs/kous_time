import 'package:flutter/material.dart';
class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Favorite"),centerTitle: true,backgroundColor: Colors.white),
      body: Center(
        child:Text("No favorite yet"),
    ),

    );
  }
}
