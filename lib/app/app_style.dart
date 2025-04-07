import 'package:aivis/widgets/rectangular_indicator.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppColors {
  // 使用 M3 推荐的种子颜色生成方案
  // static ColorScheme lightColorScheme = ColorScheme.fromSeed(
  //   seedColor: const Color(0xFF0062A0), // 更符合 M3 的蓝色
  //   brightness: Brightness.light,
  // );
  //
  // static ColorScheme darkColorScheme = ColorScheme.fromSeed(
  //   seedColor: const Color(0xFF5BA4D0), // 更亮的种子色以适应暗色模式
  //   brightness: Brightness.dark,
  // );

  // 添加 M3 扩展颜色 (可选)
  static const Color successColor = Color(0xFF2E7D32);
  static const Color warningColor = Color(0xFFF9A825);
  static const Color errorColor = Color(0xFFC62828);
  static const Color infoColor = Color(0xFF0277BD);
}

class AppStyle {
  static ThemeData lightTheme = FlexThemeData.light(
    // Using FlexColorScheme built-in FlexScheme enum based colors
    scheme: FlexScheme.greenM3,
    // Component theme configurations for light mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  static ThemeData darkTheme = FlexThemeData.dark(
    // Using FlexColorScheme built-in FlexScheme enum based colors.
    scheme: FlexScheme.greenM3,
    // Component theme configurations for dark mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  // static ThemeData lightTheme = ThemeData(
  //   useMaterial3: true, // 启用 Material 3
  //   colorScheme: AppColors.lightColorScheme,
  //   appBarTheme: AppBarTheme(
  //     elevation: 0,
  //     centerTitle: true,
  //     scrolledUnderElevation: 2, // M3 滚动效果
  //     backgroundColor: AppColors.lightColorScheme.surface,
  //     foregroundColor: AppColors.lightColorScheme.onSurface,
  //   ),
  //   scaffoldBackgroundColor: AppColors.lightColorScheme.background,
  //   radioTheme: RadioThemeData(
  //     fillColor: MaterialStateProperty.resolveWith<Color?>((
  //       Set<MaterialState> states,
  //     ) {
  //       if (states.contains(MaterialState.selected)) {
  //         return AppColors.lightColorScheme.primary;
  //       }
  //       return AppColors.lightColorScheme.onSurfaceVariant;
  //     }),
  //   ),
  //   checkboxTheme: CheckboxThemeData(
  //     fillColor: MaterialStateProperty.resolveWith<Color?>((
  //       Set<MaterialState> states,
  //     ) {
  //       if (states.contains(MaterialState.selected)) {
  //         return AppColors.lightColorScheme.primary;
  //       }
  //       return null;
  //     }),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(4), // M3 标准圆角
  //     ),
  //     side: BorderSide(color: AppColors.lightColorScheme.outline, width: 1.5),
  //   ),
  //   tabBarTheme: TabBarTheme(
  //     labelColor: AppColors.lightColorScheme.primary,
  //     unselectedLabelColor: AppColors.lightColorScheme.onSurfaceVariant,
  //     indicatorSize: TabBarIndicatorSize.tab,
  //     indicator: RectangularIndicator(
  //       color: AppColors.lightColorScheme.primaryContainer,
  //       topLeftRadius: 24,
  //       bottomLeftRadius: 24,
  //       topRightRadius: 24,
  //       bottomRightRadius: 24,
  //       verticalPadding: 8,
  //       horizontalPadding: 0,
  //     ),
  //     dividerColor: Colors.transparent,
  //   ),
  //   // 添加 M3 组件样式
  //   elevatedButtonTheme: ElevatedButtonThemeData(
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: AppColors.lightColorScheme.primary,
  //       foregroundColor: AppColors.lightColorScheme.onPrimary,
  //       elevation: 1,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20), // M3 按钮圆角
  //       ),
  //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //     ),
  //   ),
  //   cardTheme: CardTheme(
  //     elevation: 1,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12), // M3 卡片圆角
  //     ),
  //     margin: const EdgeInsets.all(8),
  //     color: AppColors.lightColorScheme.surface,
  //   ),
  // );
  //
  // static ThemeData darkTheme = ThemeData(
  //   useMaterial3: true,
  //   colorScheme: AppColors.darkColorScheme,
  //   appBarTheme: AppBarTheme(
  //     elevation: 0,
  //     systemOverlayStyle: SystemUiOverlayStyle(
  //       statusBarBrightness: Brightness.light,
  //       statusBarColor: Colors.transparent,
  //     ),
  //     centerTitle: true,
  //     scrolledUnderElevation: 2,
  //     backgroundColor: AppColors.darkColorScheme.surface,
  //     foregroundColor: AppColors.darkColorScheme.onSurface,
  //   ),
  //   radioTheme: RadioThemeData(
  //     fillColor: MaterialStateProperty.resolveWith<Color?>((
  //       Set<MaterialState> states,
  //     ) {
  //       if (states.contains(MaterialState.selected)) {
  //         return AppColors.darkColorScheme.primary;
  //       }
  //       return AppColors.darkColorScheme.onSurfaceVariant;
  //     }),
  //   ),
  //   checkboxTheme: CheckboxThemeData(
  //     fillColor: MaterialStateProperty.resolveWith<Color?>((
  //       Set<MaterialState> states,
  //     ) {
  //       if (states.contains(MaterialState.selected)) {
  //         return AppColors.darkColorScheme.primary;
  //       }
  //       return null;
  //     }),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  //     side: BorderSide(color: AppColors.darkColorScheme.outline, width: 1.5),
  //   ),
  //   tabBarTheme: TabBarTheme(
  //     labelColor: AppColors.darkColorScheme.primary,
  //     unselectedLabelColor: AppColors.darkColorScheme.onSurfaceVariant,
  //     indicatorSize: TabBarIndicatorSize.tab,
  //     indicator: RectangularIndicator(
  //       color: AppColors.darkColorScheme.primaryContainer,
  //       topLeftRadius: 24,
  //       bottomLeftRadius: 24,
  //       topRightRadius: 24,
  //       bottomRightRadius: 24,
  //       verticalPadding: 8,
  //       horizontalPadding: 0,
  //     ),
  //     dividerColor: Colors.transparent,
  //   ),
  //   elevatedButtonTheme: ElevatedButtonThemeData(
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: AppColors.darkColorScheme.primary,
  //       foregroundColor: AppColors.darkColorScheme.onPrimary,
  //       elevation: 1,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //     ),
  //   ),
  //   cardTheme: CardTheme(
  //     elevation: 1,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     margin: const EdgeInsets.all(8),
  //     color: AppColors.darkColorScheme.surface,
  //   ),
  // );

  // 间距和尺寸工具保持不变
  static const vGap4 = SizedBox(height: 4);
  static const vGap8 = SizedBox(height: 8);
  static const vGap12 = SizedBox(height: 12);
  static const vGap24 = SizedBox(height: 24);
  static const vGap32 = SizedBox(height: 32);
  static const vGap48 = SizedBox(height: 48);

  static const hGap4 = SizedBox(width: 4);
  static const hGap8 = SizedBox(width: 8);
  static const hGap12 = SizedBox(width: 12);
  static const hGap16 = SizedBox(width: 16);
  static const hGap24 = SizedBox(width: 24);
  static const hGap32 = SizedBox(width: 32);
  static const hGap48 = SizedBox(width: 48);

  static const edgeInsetsH4 = EdgeInsets.symmetric(horizontal: 4);
  static const edgeInsetsH8 = EdgeInsets.symmetric(horizontal: 8);
  static const edgeInsetsH12 = EdgeInsets.symmetric(horizontal: 12);
  static const edgeInsetsH16 = EdgeInsets.symmetric(horizontal: 16);
  static const edgeInsetsH20 = EdgeInsets.symmetric(horizontal: 20);
  static const edgeInsetsH24 = EdgeInsets.symmetric(horizontal: 24);

  static const edgeInsetsV4 = EdgeInsets.symmetric(vertical: 4);
  static const edgeInsetsV8 = EdgeInsets.symmetric(vertical: 8);
  static const edgeInsetsV12 = EdgeInsets.symmetric(vertical: 12);
  static const edgeInsetsV24 = EdgeInsets.symmetric(vertical: 24);

  static const edgeInsetsA4 = EdgeInsets.all(4);
  static const edgeInsetsA8 = EdgeInsets.all(8);
  static const edgeInsetsA12 = EdgeInsets.all(12);
  static const edgeInsetsA16 = EdgeInsets.all(16);
  static const edgeInsetsA20 = EdgeInsets.all(20);
  static const edgeInsetsA24 = EdgeInsets.all(24);

  static const edgeInsetsR4 = EdgeInsets.only(right: 4);
  static const edgeInsetsR8 = EdgeInsets.only(right: 8);
  static const edgeInsetsR12 = EdgeInsets.only(right: 12);
  static const edgeInsetsR16 = EdgeInsets.only(right: 16);
  static const edgeInsetsR20 = EdgeInsets.only(right: 20);
  static const edgeInsetsR24 = EdgeInsets.only(right: 24);

  static const edgeInsetsL4 = EdgeInsets.only(left: 4);
  static const edgeInsetsL8 = EdgeInsets.only(left: 8);
  static const edgeInsetsL12 = EdgeInsets.only(left: 12);
  static const edgeInsetsL16 = EdgeInsets.only(left: 16);
  static const edgeInsetsL20 = EdgeInsets.only(left: 20);
  static const edgeInsetsL24 = EdgeInsets.only(left: 24);

  static const edgeInsetsT4 = EdgeInsets.only(top: 4);
  static const edgeInsetsT8 = EdgeInsets.only(top: 8);
  static const edgeInsetsT12 = EdgeInsets.only(top: 12);
  static const edgeInsetsT24 = EdgeInsets.only(top: 24);

  static const edgeInsetsB4 = EdgeInsets.only(bottom: 4);
  static const edgeInsetsB8 = EdgeInsets.only(bottom: 8);
  static const edgeInsetsB12 = EdgeInsets.only(bottom: 12);
  static const edgeInsetsB24 = EdgeInsets.only(bottom: 24);

  static BorderRadius radius4 = BorderRadius.circular(4);
  static BorderRadius radius8 = BorderRadius.circular(8);
  static BorderRadius radius12 = BorderRadius.circular(12);
  static BorderRadius radius24 = BorderRadius.circular(24);
  static BorderRadius radius32 = BorderRadius.circular(32);
  static BorderRadius radius48 = BorderRadius.circular(48);

  /// 顶部状态栏的高度
  static double get statusBarHeight => MediaQuery.of(Get.context!).padding.top;

  /// 底部导航条的高度
  static double get bottomBarHeight =>
      MediaQuery.of(Get.context!).padding.bottom;
}
