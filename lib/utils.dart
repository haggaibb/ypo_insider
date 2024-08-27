import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';




class MainLoading extends StatelessWidget {
  const MainLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitRotatingCircle(
        color: Colors.blue,
        size: 80.0,
      ),
    );
  }
}

class ResultsLoading extends StatelessWidget {
  const ResultsLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(80.0),
        child: SpinKitThreeInOut(
          color: Colors.blue,
          size: 80.0,
        ),
      ),
    );
  }
}
