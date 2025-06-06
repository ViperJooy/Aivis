import 'dart:async';

import 'package:aivis/app/app_error.dart';
import 'package:aivis/app/event_bus.dart';
import 'package:aivis/app/log.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class BaseController extends GetxController {
  /// 加载中，更新页面
  var pageLoadding = false.obs;

  /// 加载中,不会更新页面
  var loadding = false;

  /// 空白页面
  var pageEmpty = false.obs;

  /// 页面错误
  var pageError = false.obs;

  /// 未登录
  var notLogin = false.obs;

  /// 错误信息
  var errorMsg = "".obs;

  StreamSubscription<dynamic>? loginSubscription;
  StreamSubscription<dynamic>? logoutSubscription;
  @override
  void onInit() {
    loginSubscription = EventBus.instance.listen(
      EventBus.kLogined,
      (p0) => onLogin(),
    );
    logoutSubscription = EventBus.instance.listen(
      EventBus.kLogouted,
      (p0) => onLogout(),
    );
    super.onInit();
  }

  @override
  void onClose() {
    loginSubscription?.cancel();
    logoutSubscription?.cancel();
    super.onClose();
  }

  /// 显示错误
  /// * [msg] 错误信息
  /// * [showPageError] 显示页面错误
  /// * 只在第一页加载错误时showPageError=true，后续页加载错误时使用Toast弹出通知
  void handleError(Object exception, {bool showPageError = false}) {
    Log.logPrint(exception);
    var msg = exceptionToString(exception);
    if (exception is AppError && exception.notLogin) {
      notLogin.value = true;
      pageError.value = false;
      return;
    }
    if (showPageError) {
      pageError.value = true;
      errorMsg.value = msg;
    } else {
      Fluttertoast.showToast(msg: exceptionToString(msg));
    }
  }

  String exceptionToString(Object exception) {
    if (exception is AppError) {
      return exception.toString();
    }
    return exception.toString().replaceAll("Exception:", "");
  }

  void onLogin() {}
  void onLogout() {}
}

class BasePageController<T> extends BaseController {
  final ScrollController scrollController = ScrollController();
  final EasyRefreshController easyRefreshController = EasyRefreshController();
  int currentPage = 1;
  int count = 0;
  int maxPage = 0;
  int pageSize = 15;
  var canLoadMore = false.obs;
  var list = <T>[].obs;

  Future refreshData() async {
    currentPage = 1;
    list.value = [];
    await loadData();
  }

  Future loadData() async {
    try {
      if (loadding) return;
      loadding = true;
      pageError.value = false;
      pageEmpty.value = false;
      notLogin.value = false;
      pageLoadding.value = currentPage == 1;

      var result = await getData(currentPage, pageSize);
      //是否可以加载更多
      if (result.isNotEmpty) {
        currentPage++;
        canLoadMore.value = true;
        pageEmpty.value = false;
      } else {
        canLoadMore.value = false;
        if (currentPage == 1) {
          pageEmpty.value = true;
        }
      }
      // 赋值数据
      if (currentPage == 1) {
        list.value = result;
      } else {
        list.addAll(result);
      }
    } catch (e) {
      handleError(e, showPageError: currentPage == 1);
    } finally {
      loadding = false;
      pageLoadding.value = false;
    }
  }

  Future<List<T>> getData(int page, int pageSize) async {
    return [];
  }

  void scrollToTopOrRefresh() {
    if (scrollController.offset > 0) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.linear,
      );
    } else {
      easyRefreshController.callRefresh();
    }
  }
}
