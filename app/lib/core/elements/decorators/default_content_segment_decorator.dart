import 'package:flutter/material.dart';

import '../../themes/theme_context.dart';
import '../../themes/widgets/themed_surface.dart';
import '../content_segment.dart';
import '../module_element.dart';
import 'element_decorator.dart';

class DefaultContentSegmentDecorator implements ElementDecorator<ContentSegment> {
  const DefaultContentSegmentDecorator();
  @override
  Widget decorateDragged(BuildContext context, ContentSegment element, Widget child, double opacity) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(blurRadius: 8, spreadRadius: -2, color: Colors.black.withOpacity(opacity * 0.5))],
      ),
      child: child,
    );
  }

  @override
  Widget decorateElement(BuildContext context, ContentSegment element, Widget child) {
    if (child is ContentSegmentItems) {
      return child.builder(context, child.itemsBuilder(context).map((c) => _defaultDecorator(element, c)).toList());
    } else if (child is ContentSegmentText) {
      return Material(color: Colors.transparent, child: child.builder(context));
    } else {
      return _defaultDecorator(element, child);
    }
  }

  @override
  Widget decoratePlaceholder(BuildContext context, ContentSegment element) {
    return _defaultDecorator(element);
  }

  Widget _defaultDecorator(ContentSegment element, [Widget? child]) {
    var w = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ThemedSurface(
        builder: (context, fillColor) => Material(
          textStyle: TextStyle(color: context.onSurfaceColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: fillColor.withOpacity(child != null ? 1 : 0.4),
          child: child ?? Container(),
        ),
      ),
    );
    if (element.size == SegmentSize.wide) {
      return w;
    } else {
      return AspectRatio(
        aspectRatio: 1,
        child: w,
      );
    }
  }
}