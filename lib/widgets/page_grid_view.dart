import 'package:aivis/app/controller/base_controller.dart';
import 'package:aivis/widgets/status/app_empty_widget.dart';
import 'package:aivis/widgets/status/app_error_widget.dart';
import 'package:aivis/widgets/status/app_loadding_widget.dart';
import 'package:aivis/widgets/status/app_not_login_widget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

typedef IndexedWidgetBuilder = Widget Function(BuildContext context, int index);

class PageGridView extends StatelessWidget {
  final BasePageController pageController;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final EdgeInsets? padding;
  final bool firstRefresh;
  final Function()? onLoginSuccess;
  final bool showPageLoadding;
  final double crossAxisSpacing, mainAxisSpacing;
  final int crossAxisCount;
  const PageGridView({
    required this.itemBuilder,
    required this.pageController,
    this.padding,
    this.firstRefresh = false,
    this.showPageLoadding = false,
    this.separatorBuilder,
    this.onLoginSuccess,
    this.crossAxisSpacing = 0.0,
    this.mainAxisSpacing = 0.0,
    required this.crossAxisCount,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        children: [
          EasyRefresh(
            header: const MaterialHeader(),
            footer: const MaterialFooter(infiniteOffset: 100, clamping: false),
            controller: pageController.easyRefreshController,
            refreshOnStart: firstRefresh,
            onLoad: pageController.loadData,
            onRefresh: pageController.refreshData,
            child: MasonryGridView.count(
              padding: padding,
              itemCount: pageController.list.length,
              itemBuilder: itemBuilder,
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              controller: pageController.scrollController,
            ),
          ),
          Offstage(
            offstage: !pageController.pageEmpty.value,
            child: AppEmptyWidget(
              onRefresh: () => pageController.refreshData(),
            ),
          ),
          Offstage(
            offstage: !(showPageLoadding && pageController.pageLoadding.value),
            child: const AppLoaddingWidget(),
          ),
          Offstage(
            offstage: !pageController.pageError.value,
            child: AppErrorWidget(
              errorMsg: pageController.errorMsg.value,
              onRefresh: () => pageController.refreshData(),
            ),
          ),
          Offstage(
            offstage: !pageController.notLogin.value,
            child: AppNotLoginWidget(onLoginSuccess: onLoginSuccess),
          ),
        ],
      ),
    );
  }
}
