import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class TestPage extends StatelessWidget {
  @override
  Widget build(context) {
    // 使用Get.put()实例化你的类，使其对当下的所有子路由可用。
    final TestController c = Get.put(TestController());

    return Scaffold(
      // 使用Obx(()=>每当改变计数时，就更新Text()。
      appBar: AppBar(title: Obx(() => Text("Clicks: ${c.count}"))),

      // 用一个简单的Get.to()即可代替Navigator.push那8行，无需上下文！
      body: Center(
        child: ElevatedButton(
          child: Text("Go to Other"),
          onPressed: () => Get.to(Other()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: c.increment,
      ),
    );
  }
}

class Other extends GetView<TestController> {
  @override
  Widget build(context) {
    // 访问更新后的计数变量
    return Scaffold(body: Center(child: Text("${controller.count}")));
  }
}
