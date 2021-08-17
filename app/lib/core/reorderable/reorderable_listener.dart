import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../areas/areas.dart';
import '../module/module.dart';
import 'logic_provider.dart';
import 'reorderable_item.dart';

class ReorderableListener<T extends ModuleElement> extends StatelessWidget {
  const ReorderableListener({
    Key? key,
    required this.child,
    this.delay = kLongPressTimeout,
  }) : super(key: key);

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        _startDragging(context: context, event: event);
      },
      child: child,
    );
  }

  void _startDragging({required BuildContext context, required PointerDownEvent event}) {
    ReorderableItemState state = context.findAncestorStateOfType<ReorderableItemState>()!;
    var widgetArea = WidgetArea.of<T>(context)!;

    context.read(reorderableLogicProvider).startDragging(
          key: state.key,
          event: event,
          widgetArea: widgetArea,
          recognizer: DelayedMultiDragGestureRecognizer(delay: delay, debugOwner: this, kind: event.kind),
        );
  }
}