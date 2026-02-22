import 'package:flutter/material.dart';
import '../constants/color_constants.dart';

// String Extensions
extension StringExtensions on String {
  // Check if string is null or empty
  bool get isNullOrEmpty => isEmpty;

  // Check if string is not null or empty
  bool get isNotNullOrEmpty => isNotEmpty;

  // Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  // Title case
  String get toTitleCase {
    return split(' ')
        .map((word) => word.isEmpty ? word : word.capitalize)
        .join(' ');
  }

  // Remove whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s'), '');

  // Is valid email
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }

  // Is valid phone
  bool get isValidPhone {
    return RegExp(r'^\+?[\d\s\-()]{10,}$').hasMatch(this);
  }

  // Is numeric
  bool get isNumeric => RegExp(r'^\d+$').hasMatch(this);

  // To int safely
  int? get toIntOrNull => int.tryParse(this);

  // To double safely
  double? get toDoubleOrNull => double.tryParse(this);

  // Truncate with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  // Get initials
  String get initials {
    final parts = trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}

// Nullable String Extensions
extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
  String get orEmpty => this ?? '';
}

// DateTime Extensions
extension DateTimeExtensions on DateTime {
  // Is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  // Is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  // Is same day
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  // Start of day
  DateTime get startOfDay => DateTime(year, month, day);

  // End of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  // Add days
  DateTime addDays(int days) => add(Duration(days: days));

  // Subtract days
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  // Age calculation
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }
}

// BuildContext Extensions
extension BuildContextExtensions on BuildContext {
  // Media Query
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  // Responsiveness
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;

  // Theme
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // Navigation
  NavigatorState get navigator => Navigator.of(this);
  void pop<T>([T? result]) => navigator.pop(result);
  Future<T?> push<T>(Route<T> route) => navigator.push(route);
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      navigator.pushNamed(routeName, arguments: arguments);
  Future<T?> pushReplacement<T, TO>(Route<T> route, {TO? result}) =>
      navigator.pushReplacement(route, result: result);
  Future<T?> pushReplacementNamed<T, TO>(String routeName,
      {TO? result, Object? arguments}) =>
      navigator.pushReplacementNamed(routeName,
          result: result, arguments: arguments);
  void popUntil(RoutePredicate predicate) => navigator.popUntil(predicate);
  Future<T?> pushAndRemoveUntil<T>(
      Route<T> route, RoutePredicate predicate) =>
      navigator.pushAndRemoveUntil(route, predicate);

  // Snackbar
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);
  void showSnackBar(String message, {bool isError = false}) {
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Hide keyboard
  void hideKeyboard() => FocusScope.of(this).unfocus();
}

// List Extensions
extension ListExtensions<T> on List<T> {
  // Safe get
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  // First or null
  T? get firstOrNull => isEmpty ? null : first;

  // Last or null
  T? get lastOrNull => isEmpty ? null : last;

  // Separate with
  List<T> separateWith(T separator) {
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}

// Map Extensions
extension MapExtensions<K, V> on Map<K, V> {
  // Get or default
  V getOrDefault(K key, V defaultValue) {
    return containsKey(key) ? this[key]! : defaultValue;
  }

  // Safe get
  V? getOrNull(K key) => containsKey(key) ? this[key] : null;
}

// Num Extensions
extension NumExtensions on num {
  // Duration helpers
  Duration get milliseconds => Duration(milliseconds: toInt());
  Duration get seconds => Duration(seconds: toInt());
  Duration get minutes => Duration(minutes: toInt());
  Duration get hours => Duration(hours: toInt());
  Duration get days => Duration(days: toInt());

  // Spacing helpers
  SizedBox get heightBox => SizedBox(height: toDouble());
  SizedBox get widthBox => SizedBox(width: toDouble());

  // Padding helpers
  EdgeInsets get allPadding => EdgeInsets.all(toDouble());
  EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsets get verticalPadding => EdgeInsets.symmetric(vertical: toDouble());

  // Border radius
  BorderRadius get circular => BorderRadius.circular(toDouble());
  Radius get circularRadius => Radius.circular(toDouble());
}

// Widget Extensions
extension WidgetExtensions on Widget {
  // Padding
  Widget padding(EdgeInsets padding) => Padding(padding: padding, child: this);
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(
        padding:
        EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        child: this,
      );
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      Padding(
        padding:
        EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
        child: this,
      );

  // Center
  Widget get center => Center(child: this);

  // Expanded
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  // Flexible
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) =>
      Flexible(flex: flex, fit: fit, child: this);

  // SizedBox
  Widget sizedBox({double? width, double? height}) =>
      SizedBox(width: width, height: height, child: this);

  // Opacity
  Widget opacity(double opacity) => Opacity(opacity: opacity, child: this);

  // Visibility
  Widget visible(bool visible) =>
      Visibility(visible: visible, child: this);

  // GestureDetector
  Widget onTap(VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: this);

  // Hero
  Widget hero(String tag) => Hero(tag: tag, child: this);

  // SafeArea
  Widget get safeArea => SafeArea(child: this);

  // Sliver
  Widget get toSliver => SliverToBoxAdapter(child: this);
}