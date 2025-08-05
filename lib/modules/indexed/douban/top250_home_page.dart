import 'package:aivis/app/app_style.dart';
import 'package:aivis/modules/indexed/douban/top250_home_controller.dart';
import 'package:aivis/modules/indexed/douban/top250_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Top250HomePage extends GetView<Top250HomeController> {
  const Top250HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: Text("豆瓣Top250",style: const TextStyle(fontSize: 18,  fontWeight: FontWeight.bold)),
        // title: Container(
        //   alignment: Alignment.centerLeft,
        //   child: TabBar(
        //     controller: controller.tabController,
        //     padding: EdgeInsets.zero,
        //     tabs: controller.tabs.map((e) => Tab(text: e.tr)).toList(),
        //     labelPadding: AppStyle.edgeInsetsH20,
        //     isScrollable: true,
        //     indicatorSize: TabBarIndicatorSize.tab,
        //   ),
        // ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: controller.tabs.map((e) => Top250ListView(e)).toList(),
      ),
    );
  }
}
