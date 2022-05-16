import 'package:flutter/material.dart';
import 'package:riverpod_context/riverpod_context.dart';

import 'drag_provider.dart';
import 'items_provider.dart';

enum ReorderableState { normal, placeholder, dragging }

typedef DecorationBuilder = Widget Function(BuildContext context, Widget widget, double opacity);
typedef ReorderableBuilder = Widget Function(BuildContext context, ReorderableState state, Widget child);

class ReorderableItem extends StatefulWidget {
  const ReorderableItem({
    required Key key,
    required this.builder,
    required this.decorationBuilder,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final ReorderableBuilder builder;
  final DecorationBuilder decorationBuilder;

  @override
  ReorderableItemState createState() => ReorderableItemState();
}

class ReorderableItemState extends State<ReorderableItem> {
  late ReorderableItemLogic logic;

  Key get key => widget.key!;

  @override
  void initState() {
    super.initState();
    logic = context.read(reorderableItemProvider);
    logic.register(this);
  }

  @override
  void didUpdateWidget(ReorderableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (context.read(isDraggingProvider(key))) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        context.read(dragWidgetProvider.state).state = widget.builder(context, ReorderableState.dragging, widget.child);
      });
    }
  }

  @override
  void dispose() {
    logic.unregister(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logic.update(this);
    var isDragging = context.watch(isDraggingProvider(key));
    var animation = context.watch(itemAnimationProvider(key));
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform(
        transform: Matrix4.translationValues(animation.value.dx, animation.value.dy, 0.0),
        child: child,
      ),
      child: isDragging
          ? SizedBox.fromSize(
              size: context.read(dragSizeProvider.state).state,
              child: widget.builder(context, ReorderableState.placeholder, widget.child),
            )
          : widget.builder(context, ReorderableState.normal, widget.child),
    );
  }
}
