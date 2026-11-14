import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A global wrapper widget that enables keyboard arrow keys (and page up/down, space, home, end)
/// for scrolling any active [Scrollable] across the entire app.
class GlobalKeyboardScroll extends StatefulWidget {
  final Widget child;
  const GlobalKeyboardScroll({super.key, required this.child});

  @override
  State<GlobalKeyboardScroll> createState() => _GlobalKeyboardScrollState();
}

class _GlobalKeyboardScrollState extends State<GlobalKeyboardScroll> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _isEditingText() {
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null) return false;
    final widget = primaryFocus.context?.widget;
    if (widget is EditableText) return true;
    final ancestor =
        primaryFocus.context?.findAncestorWidgetOfExactType<EditableText>();
    return ancestor != null;
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return false;
    }

    if (_isEditingText()) {
      return false;
    }

    final key = event.logicalKey;
    final isDown = key == LogicalKeyboardKey.arrowDown;
    final isUp = key == LogicalKeyboardKey.arrowUp;
    final isRight = key == LogicalKeyboardKey.arrowRight;
    final isLeft = key == LogicalKeyboardKey.arrowLeft;
    final isPageDown = key == LogicalKeyboardKey.pageDown;
    final isPageUp = key == LogicalKeyboardKey.pageUp;
    final isSpace = key == LogicalKeyboardKey.space;
    final isHome = key == LogicalKeyboardKey.home;
    final isEnd = key == LogicalKeyboardKey.end;

    if (!isDown &&
        !isUp &&
        !isRight &&
        !isLeft &&
        !isPageDown &&
        !isPageUp &&
        !isSpace &&
        !isHome &&
        !isEnd) {
      return false;
    }

    final isHorizontal = isRight || isLeft;
    final position = _findScrollPosition(context, isHorizontal: isHorizontal);

    if (position != null && position.hasPixels) {
      const double lineStep = 90.0;
      const double pageStep = 420.0;
      double delta = 0.0;

      if (isDown) {
        delta = lineStep;
      } else if (isUp) {
        delta = -lineStep;
      } else if (isRight) {
        delta = lineStep;
      } else if (isLeft) {
        delta = -lineStep;
      } else if (isPageDown) {
        delta = pageStep;
      } else if (isPageUp) {
        delta = -pageStep;
      } else if (isSpace) {
        final isShift = HardwareKeyboard.instance.isShiftPressed;
        delta = isShift ? -pageStep : pageStep;
      } else if (isHome) {
        delta = -999999.0;
      } else if (isEnd) {
        delta = 999999.0;
      }

      final target = (position.pixels + delta).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );

      if ((target - position.pixels).abs() > 0.1) {
        position.animateTo(
          target,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
        );
        return true;
      }
    }

    return false;
  }

  ScrollPosition? _findScrollPosition(BuildContext rootContext, {required bool isHorizontal}) {
    // 1. Try currently focused context first
    final focusedCtx = FocusManager.instance.primaryFocus?.context;
    if (focusedCtx != null) {
      final pos = _findInContext(focusedCtx, isHorizontal: isHorizontal);
      if (pos != null) return pos;
    }

    // 2. Try root context
    return _findInContext(rootContext, isHorizontal: isHorizontal);
  }

  ScrollPosition? _findInContext(BuildContext context, {required bool isHorizontal}) {
    // Check ancestor ScrollableState
    final scrollable = context.findAncestorStateOfType<ScrollableState>();
    if (scrollable != null && scrollable.position.hasPixels) {
      final isVert = scrollable.axisDirection == AxisDirection.down ||
          scrollable.axisDirection == AxisDirection.up;
      if (isHorizontal && !isVert) {
        return scrollable.position;
      } else if (!isHorizontal && isVert) {
        return scrollable.position;
      }
    }

    // Check PrimaryScrollController
    final primary = PrimaryScrollController.maybeOf(context);
    if (primary != null && primary.hasClients && primary.position.hasPixels) {
      if (!isHorizontal || primary.position.axis == Axis.horizontal) {
        return primary.position;
      }
    }

    // Traverse child elements to find active ScrollableState
    ScrollPosition? found;
    void visitor(Element element) {
      if (found != null) return;
      if (element is StatefulElement) {
        final state = element.state;
        if (state is ScrollableState && state.position.hasPixels) {
          final isVert = state.axisDirection == AxisDirection.down ||
              state.axisDirection == AxisDirection.up;
          if (isHorizontal && !isVert) {
            found = state.position;
            return;
          } else if (!isHorizontal && isVert) {
            found = state.position;
            return;
          }
        }
      }
      element.visitChildElements(visitor);
    }

    context.visitChildElements(visitor);
    return found;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Convenience alias
typedef KeyboardScroll = GlobalKeyboardScroll;
