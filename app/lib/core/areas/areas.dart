library areas;

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_context/riverpod_context.dart';

import '../../providers/trips/logic_provider.dart';
import '../../providers/trips/selected_trip_provider.dart';
import '../elements/elements.dart';
import '../module/module.dart';
import '../reorderable/logic_provider.dart';
import '../templates/templates.dart';
import '../themes/themes.dart';

part 'body_widget_area.dart';
part 'full_page_area.dart';
part 'quick_action_row_area.dart';

class InheritedWidgetArea<T extends ModuleElement> extends InheritedWidget {
  final WidgetAreaState<WidgetArea<T>, T> state;

  const InheritedWidgetArea({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidgetArea oldWidget) => true;
}

final areaModulesProvider = Provider.family<List<String>, String>(
  (ref, String id) {
    var trip = ref.watch(selectedTripProvider);
    return trip?.modules[id] ?? [];
  },
);

abstract class WidgetArea<T extends ModuleElement> extends StatefulWidget {
  final String id;
  const WidgetArea(this.id, {Key? key}) : super(key: key);

  static WidgetAreaState<WidgetArea<T>, T>? of<T extends ModuleElement>(BuildContext context) {
    assert(T != ModuleElement, 'WidgetArea.of was called with default type parameter. This is probably not right.');
    var element = context.getElementForInheritedWidgetOfExactType<InheritedWidgetArea<T>>();
    return element != null ? (element.widget as InheritedWidgetArea<T>).state : null;
  }
}

abstract class WidgetAreaState<U extends WidgetArea<T>, T extends ModuleElement> extends State<U>
    with AutomaticKeepAliveClientMixin {
  bool _isInitialized = false;

  String get id => widget.id;

  final _areaKey = GlobalKey();
  final _areaTheme = ValueNotifier<ThemeState?>(null);
  late Size _areaSize;
  late Offset _areaOffset;

  Size get areaSize => _areaSize;
  Offset get areaOffset => _areaOffset;

  ThemeState get theme => _areaTheme.value!;
  WidgetTemplateState get template => WidgetTemplate.of(context, listen: false);

  Type get elementType => T;

  @override
  bool get wantKeepAlive => false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;
    _isInitialized = true;

    reload();
    context.listen(areaModulesProvider(id), (_, __) => reload());
  }

  Future<void> reload() async {
    var widgets = await template.getWidgetsForArea<T>(widget.id);
    initArea(widgets);
    setState(() {});
  }

  void initArea(List<T> widgets);

  void updateAreaSize(_) {
    _areaSize = (_areaKey.currentContext!.findRenderObject()! as RenderBox).size;
    _areaOffset = (_areaKey.currentContext!.findRenderObject()! as RenderBox).localToGlobal(Offset.zero);
  }

  bool get isSelected => template.selectedArea == id;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var templateState = WidgetTemplate.of(context);
    templateState.registerArea(this);

    var isSelected = templateState.selectedArea == id;
    var backgroundColor = Colors.blue.withOpacity(0.05);
    var borderColor = Colors.blue.withOpacity(0.5);

    WidgetsBinding.instance!.addPostFrameCallback(updateAreaSize);

    return InheritedWidgetArea(
      state: this,
      child: Listener(
        onPointerDown: (_) {
          templateState.selectWidgetArea<T>(this);
        },
        child: ThemedContainer(
          themeNotifier: _areaTheme,
          child: Container(
            margin: getMargin(),
            padding: getPadding(),
            decoration: isSelected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: backgroundColor,
                    border: Border.all(color: borderColor),
                  )
                : null,
            child: Container(key: _areaKey, child: buildArea(context)),
          ),
        ),
      ),
    );
  }

  Widget buildArea(BuildContext context);

  EdgeInsetsGeometry getMargin() => EdgeInsets.zero;
  EdgeInsetsGeometry getPadding() => const EdgeInsets.all(10);

  Widget? decoratePlaceholder(BuildContext context, T element) => null;
  Widget? decorateElement(BuildContext context, T element) => null;

  BoxConstraints constrainWidget(T widget);

  void removeWidget(Key key) {
    setState(() {
      var widget = getWidgetFromKey(key);
      removeItem(key);
      widget.onRemoved(context);

      var templateState = WidgetTemplate.of(context, listen: false);
      templateState.onWidgetRemoved(this, widget);
    });
    updateWidgetsInTrip();
  }

  void removeWidgetWithId(String id) {
    for (var w in getWidgets().where((w) => w.id.endsWith(id))) {
      removeWidget(w.key);
    }
  }

  Future<void> updateWidgetsInTrip() async {
    context.read(tripsLogicProvider).updateTrip({
      'modules.$id': getWidgets().map((w) => w.id).toList(),
    });
  }

  void onDrop() {
    updateWidgetsInTrip();
  }

  void cancelDrop(Key key) {
    setState(() {
      removeItem(key);
    });
  }

  ReorderableLogic get logic => context.read(reorderableLogicProvider);

  Offset getOffset(Key key) => logic.itemOffset(key) - areaOffset;
  Size getSize(Key key) => logic.itemSize(key);
  void translateX(Key key, double delta) => logic.translateItemX(this, key, delta);
  void translateY(Key key, double delta) => logic.translateItemY(this, key, delta);

  bool isOverArea(Offset offset, Size size) {
    var areaRect = Rect.fromLTWH(0, 0, areaSize.width, areaSize.height);
    var itemRect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    return itemRect.overlaps(areaRect);
  }

  bool _scheduledRebuild = false;

  bool didInsertItem(Offset offset, T item) {
    if (_scheduledRebuild) {
      return true;
    }

    if (!isOverArea(offset, getSize(item.key))) {
      if (hasKey(item.key)) {
        cancelDrop(item.key);
      }
      return false;
    }

    if (hasKey(item.key)) {
      if (didReorderItem(offset, item.key)) {
        WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
          _scheduledRebuild = false;
        });
        _scheduledRebuild = true;
      }
      return true;
    }

    if (!canInsertItem(item)) {
      return false;
    }

    insertItem(item);

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      var n = 0;
      while (n++ < 100 && didReorderItem(offset, item.key)) {}
      if (n >= 100) {
        print('WARNING: REORDERING DID NOT FINISH AFTER 100 STEPS');
      }
      _scheduledRebuild = false;
    });
    _scheduledRebuild = true;

    return true;
  }

  List<T> getWidgets();
  T getWidgetFromKey(Key key);
  void removeItem(Key key);
  bool didReorderItem(Offset offset, Key itemKey);
  bool canInsertItem(T item) => true;
  void insertItem(T item);
  bool hasKey(Key key);
}
