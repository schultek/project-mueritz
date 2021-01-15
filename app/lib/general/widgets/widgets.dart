library widgets;

import 'dart:math';

import 'package:flutter/material.dart';

import '../areas/areas.dart';
import '../module/module.dart';
import '../route/route.dart';
import '../templates/templates.dart';

part 'body_segment.dart';
part 'quick_action.dart';

class ModuleWidgetBuilder<T extends ModuleWidget> extends StatelessWidget {
  final Widget Function(BuildContext context) builder;
  final Widget Function(BuildContext context) placeholderBuilder;

  const ModuleWidgetBuilder({required Key key, required this.builder, required this.placeholderBuilder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (WidgetSelector.existsIn(context)) {
      return ReorderableItem(
        key: key!,
        builder: (context, state, child) {
          return state == ReorderableState.placeholder ? placeholderBuilder(context) : child;
        },
        child: ReorderableListener<T>(
          delay: const Duration(milliseconds: 200),
          child: AbsorbPointer(child: builder(context)),
        ),
      );
    }

    var moduleWidget = Builder(builder: builder);

    return ReorderableItem(
      key: key!,
      builder: (context, state, child) {
        if (state == ReorderableState.placeholder) {
          return placeholderBuilder(context);
        } else if (state == ReorderableState.normal) {
          var animation = CurvedAnimation(parent: PhasedAnimation.of(context), curve: Curves.easeInOut);
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: (animation.value - 0.5) * 0.015,
                child: child,
              );
            },
            child: child,
          );
        } else {
          return AbsorbPointer(child: moduleWidget);
        }
      },
      child: RemovableDraggableModuleWidget<T>(
        key: key!,
        child: moduleWidget,
      ),
    );
  }
}

class RemovableDraggableModuleWidget<T extends ModuleWidget> extends StatelessWidget {
  final Widget child;
  const RemovableDraggableModuleWidget({required Key key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var templateState = WidgetTemplate.of(context);

    if (templateState.isEditing) {
      return Stack(children: [
        ReorderableListener<T>(
          delay: const Duration(milliseconds: 100),
          child: AbsorbPointer(child: child),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: templateState.transition,
            builder: (context, child) {
              return ClipOval(
                clipper: ScalingClipper(templateState.transition.value, const Offset(12, 12)),
                child: child,
              );
            },
            child: Material(
              color: Colors.red, // button color
              child: InkWell(
                splashColor: Colors.redAccent,
                onTap: () {
                  var areaState = WidgetArea.of(context, listen: false);
                  areaState.removeWidget(key!);
                }, // inkwell color
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(Icons.close, size: 15, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ]);
    } else {
      return ModuleRouteTransition(child: child);
    }
  }
}

class PhasedAnimation extends CompoundAnimation<double> {
  double shift;

  PhasedAnimation({required Animation<double> phase, required Animation<double> intensity, this.shift = 0.0})
      : super(first: phase, next: intensity);

  @override
  double get value {
    var phase = first.value + shift;
    phase = phase > 1 ? phase - 1 : phase;
    phase *= 2;
    phase = phase > 1 ? 2 - phase : phase;
    return phase * next.value;
  }

  factory PhasedAnimation.of(BuildContext context) {
    var state = WidgetTemplate.of(context, listen: false);
    return PhasedAnimation(phase: state.wiggle, intensity: state.transition, shift: Random().nextDouble());
  }
}

class ScalingClipper extends CustomClipper<Rect> {
  double value;
  Offset center;

  ScalingClipper(this.value, this.center);

  @override
  Rect getClip(Size size) {
    return Rect.fromCenter(
      center: center,
      width: size.width * value,
      height: size.height * value,
    );
  }

  @override
  bool shouldReclip(ScalingClipper oldClipper) => oldClipper.value != value;
}
