import 'package:flutter/material.dart';

enum DeviceType { mobileSmall, mobile, tablet, tabletLarge, desktop }

class Responsive {
  final BuildContext context;

  Responsive(this.context);

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;

  DeviceType get deviceType {
    if (width < 360) return DeviceType.mobileSmall;
    if (width < 481) return DeviceType.mobile;
    if (width < 769) return DeviceType.tablet;
    if (width < 1025) return DeviceType.tabletLarge;
    return DeviceType.desktop;
  }

  bool get isMobile => deviceType == DeviceType.mobileSmall || deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet || deviceType == DeviceType.tabletLarge;
  bool get isDesktop => deviceType == DeviceType.desktop;

  int get gridCrossAxisCount {
    switch (deviceType) {
      case DeviceType.mobileSmall:
        return 3;
      case DeviceType.mobile:
        return 3;
      case DeviceType.tablet:
        return 4;
      case DeviceType.tabletLarge:
        return 5;
      case DeviceType.desktop:
        return 6;
    }
  }

  int get kasirGridCount {
    switch (deviceType) {
      case DeviceType.mobileSmall:
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.tabletLarge:
      case DeviceType.desktop:
        return 3;
    }
  }

  double get horizontalPadding {
    switch (deviceType) {
      case DeviceType.mobileSmall:
        return 12;
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 24;
      case DeviceType.tabletLarge:
        return 32;
      case DeviceType.desktop:
        return 48;
    }
  }

  double get cardFontTitle {
    switch (deviceType) {
      case DeviceType.mobileSmall:
        return 14;
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 18;
      case DeviceType.tabletLarge:
      case DeviceType.desktop:
        return 20;
    }
  }

  double get cardFontBody {
    switch (deviceType) {
      case DeviceType.mobileSmall:
        return 12;
      case DeviceType.mobile:
        return 14;
      case DeviceType.tablet:
        return 15;
      case DeviceType.tabletLarge:
      case DeviceType.desktop:
        return 16;
    }
  }

  double get iconSize {
    switch (deviceType) {
      case DeviceType.mobileSmall:
        return 36;
      case DeviceType.mobile:
        return 40;
      case DeviceType.tablet:
        return 48;
      case DeviceType.tabletLarge:
      case DeviceType.desktop:
        return 56;
    }
  }

  double get menuBoxSize {
    switch (deviceType) {
      case DeviceType.mobileSmall:
        return 60;
      case DeviceType.mobile:
        return 70;
      case DeviceType.tablet:
        return 80;
      case DeviceType.tabletLarge:
      case DeviceType.desktop:
        return 90;
    }
  }

  double get appBarFontSize {
    if (isMobile) return 18;
    if (isTablet) return 22;
    return 24;
  }

  EdgeInsets get pagePadding => EdgeInsets.all(horizontalPadding);

  T value<T>({required T mobile, required T tablet, T? desktop}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop ?? tablet;
  }
}
