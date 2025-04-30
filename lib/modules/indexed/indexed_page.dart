import 'package:aivis/generated/locales.g.dart';
import 'package:aivis/modules/indexed/indexed_controller.dart';
import 'package:aivis/routes/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class IndexedPage extends GetView<IndexedController> {
  const IndexedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.index.value,
          children: controller.pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: -10,
                      blurRadius: 60,
                      color: Colors.black.withOpacity(.20),
                      offset: Offset(0, 15),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 5,
                  ),
                  child: GNav(
                    tabs: [
                      GButton(
                        gap: 10,
                        iconActiveColor: Colors.purple,
                        iconColor: Colors.black,
                        textColor: Colors.purple,
                        backgroundColor: Colors.purple.withOpacity(.2),
                        iconSize: 24,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 5,
                        ),
                        icon: Icons.video_library,
                        text: LocaleKeys.indexed_video.tr,
                      ),
                      GButton(
                        gap: 10,
                        iconActiveColor: Colors.teal,
                        iconColor: Colors.black,
                        textColor: Colors.teal,
                        backgroundColor: Colors.teal.withOpacity(.2),
                        iconSize: 24,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 5,
                        ),
                        icon: Icons.photo,
                        text: LocaleKeys.indexed_wallpaper.tr,
                      ),
                    ],
                    selectedIndex: controller.index.value,
                    onTabChange: controller.setIndex,
                  ),
                ),
              ),
              // Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 20, top: 20, bottom: 20),
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    AppNavigator.toUserPage();
                  },
                  elevation: 3.0,
                  child: Icon(Icons.person, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Obx(
  //       () => IndexedStack(
  //         index: controller.index.value,
  //         children: controller.pages,
  //       ),
  //     ),
  //     bottomNavigationBar: Obx(
  //       () => BottomNavigationBar(
  //         currentIndex: controller.index.value,
  //         onTap: controller.setIndex,
  //         selectedFontSize: 12,
  //         unselectedFontSize: 12,
  //         iconSize: 24,
  //         type: BottomNavigationBarType.fixed,
  //         showSelectedLabels: true,
  //         showUnselectedLabels: false,
  //         elevation: 4,
  //         items: [
  //           //博客
  //           BottomNavigationBarItem(
  //             icon: const Icon(Remix.home_smile_line),
  //             activeIcon: const Icon(Remix.home_smile_fill),
  //             label: LocaleKeys.indexed_blogs.tr,
  //           ),
  //           //新闻
  //           BottomNavigationBarItem(
  //             icon: const Icon(Remix.article_line),
  //             activeIcon: const Icon(Remix.article_fill),
  //             label: LocaleKeys.indexed_news.tr,
  //           ),
  //           //闪存
  //           BottomNavigationBarItem(
  //             icon: const Icon(Remix.star_smile_line),
  //             activeIcon: const Icon(Remix.star_smile_fill),
  //             label: LocaleKeys.indexed_statuses.tr,
  //           ),
  //           //博问
  //           BottomNavigationBarItem(
  //             icon: const Icon(Remix.question_line),
  //             activeIcon: const Icon(Remix.question_fill),
  //             label: LocaleKeys.indexed_questions.tr,
  //           ),
  //           //用户
  //           BottomNavigationBarItem(
  //             icon: const Icon(Remix.user_smile_line),
  //             activeIcon: const Icon(Remix.user_smile_fill),
  //             label: LocaleKeys.indexed_user.tr,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
