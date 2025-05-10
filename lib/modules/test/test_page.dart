import 'package:aivis/modules/test/test_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TestPage extends GetView<TestController> {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TestController>(
      init: TestController(),
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('Home Page')),
        body: Center(child: Text('This is the Home Page')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            controller.navigateToSecondPage();
          },
          child: Icon(Icons.arrow_forward),
        ),
      ),
    );
  }
}
