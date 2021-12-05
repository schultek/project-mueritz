import 'package:flutter/material.dart';

import '../elements/decorators/default_page_segment_decorator.dart';
import '../elements/decorators/element_decorator.dart';
import '../elements/page_segment.dart';
import 'mixins/single_element_area_mixin.dart';
import 'widget_area.dart';

class FullPageArea extends WidgetArea<PageSegment> {
  const FullPageArea({required String id, Key? key}) : super(id, key: key);

  @override
  State<StatefulWidget> createState() => FullPageAreaState();
}

class FullPageAreaState extends WidgetAreaState<FullPageArea, PageSegment>
    with SingleElementAreaMixin<FullPageArea, PageSegment> {
  @override
  bool get wantKeepAlive => element?.keepAlive ?? super.wantKeepAlive;

  @override
  final ElementDecorator<PageSegment> elementDecorator = DefaultPageSegmentDecorator();

  @override
  EdgeInsets getMargin() =>
      template.isEditing ? const EdgeInsets.symmetric(horizontal: 10, vertical: 40) : super.getMargin();

  @override
  EdgeInsets getPadding() => template.isEditing ? super.getPadding() : EdgeInsets.zero;

  @override
  Widget buildArea(BuildContext context) {
    return element ?? const Center(child: Text('No Content'));
  }

  @override
  BoxConstraints constrainWidget(PageSegment widget) => BoxConstraints.tight(areaSize);
}
