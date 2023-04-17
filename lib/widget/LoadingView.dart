import 'package:flutter/material.dart';

class LoadingView extends StatefulWidget {
  final loading;
  Widget child;
  LoadingView({super.key, this.loading = true, required this.child});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  @override
  Widget build(BuildContext context) {
    return widget.loading
        ? const Center(
            child: CircularProgressIndicator(color: Colors.black),
          )
        : widget.child;
  }
}
