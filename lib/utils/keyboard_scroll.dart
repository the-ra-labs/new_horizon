import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Poori app ko keyboard se scroll karne deta hai:
/// ↑ ↓  |  PageUp PageDown  |  Home End  |  Space / Shift+Space
class KeyboardScroller extends StatefulWidget {
  final Widget child;
  const KeyboardScroller({super.key, required this.child});

  @override
  State<KeyboardScroller> createState() => _KeyboardScrollerState();
}

class _KeyboardScrollerState extends State<KeyboardScroller> {
  final FocusNode _node =
      FocusNode(debugLabel: 'KeyboardScroller', skipTraversal: true);

  static final Set<LogicalKeyboardKey> _keys = {
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.pageUp,
    LogicalKeyboardKey.pageDown,
    LogicalKeyboardKey.home,
    LogicalKeyboardKey.end,
    LogicalKeyboardKey.space,
  };

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  /// Text field mein typing ho rahi ho to keys cursor ke liye chhod do
  bool _editingText() {
    final ctx = FocusManager.instance.primaryFocus?.context;
    if (ctx == null) return false;
    if (ctx.widget is EditableText) return true;
    return ctx.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  /// Abhi ki (sabse upar wali) screen ka sabse bara vertical scroll dhundta hai
  ScrollPosition? _activeScroll() {
    ScrollPosition? best;
    var bestArea = -1.0;

    void visit(Element el) {
      final w = el.widget;
      if (w is Offstage && w.offstage) return;

      if (el is StatefulElement && el.state is ScrollableState) {
        final s = el.state as ScrollableState;
        final p = s.position;
        final vertical = axisDirectionToAxis(s.axisDirection) == Axis.vertical;
        if (vertical &&
            p.hasPixels &&
            p.hasContentDimensions &&
            p.maxScrollExtent - p.minScrollExtent > 1) {
          final route = ModalRoute.of(s.context);
          if (route == null || route.isCurrent) {
            final ro = s.context.findRenderObject();
            if (ro is RenderBox && ro.attached && ro.hasSize) {
              final area = ro.size.width * ro.size.height;
              if (area > bestArea) {
                bestArea = area;
                best = p;
              }
            }
          }
        }
      }
      el.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return best;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (!_keys.contains(key)) return KeyEventResult.ignored;

    final kb = HardwareKeyboard.instance;
    if (kb.isControlPressed || kb.isMetaPressed || kb.isAltPressed) {
      return KeyEventResult.ignored;
    }
    if (_editingText()) return KeyEventResult.ignored;

    final pos = _activeScroll();
    if (pos == null) return KeyEventResult.ignored;

    final page = pos.viewportDimension * 0.9;
    double target = pos.pixels;
    var ms = 120;
    Curve curve = Curves.easeOut;

    if (key == LogicalKeyboardKey.arrowDown) {
      target += 80;
      ms = 90;
      curve = Curves.linear;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      target -= 80;
      ms = 90;
      curve = Curves.linear;
    } else if (key == LogicalKeyboardKey.pageDown) {
      target += page;
      ms = 260;
    } else if (key == LogicalKeyboardKey.pageUp) {
      target -= page;
      ms = 260;
    } else if (key == LogicalKeyboardKey.space) {
      target += kb.isShiftPressed ? -page : page;
      ms = 260;
    } else if (key == LogicalKeyboardKey.home) {
      target = pos.minScrollExtent;
      ms = 450;
      curve = Curves.easeInOut;
    } else if (key == LogicalKeyboardKey.end) {
      target = pos.maxScrollExtent;
      ms = 450;
      curve = Curves.easeInOut;
    }

    target =
        target.clamp(pos.minScrollExtent, pos.maxScrollExtent).toDouble();
    if ((target - pos.pixels).abs() < 0.5) return KeyEventResult.handled;

    pos.animateTo(target, duration: Duration(milliseconds: ms), curve: curve);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _node,
      autofocus: true,
      onKeyEvent: _onKey,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        // Khali jagah par click karo to text field se focus hat jaye,
        // taake keyboard scroll dobara kaam kare
        onTap: () {
          if (_editingText()) FocusManager.instance.primaryFocus?.unfocus();
        },
        child: widget.child,
      ),
    );
  }
}
