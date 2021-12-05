import 'package:flutter/material.dart';

import '../../themes/theme_context.dart';
import '../../themes/trip_theme_data.dart';
import '../../themes/widgets/themed_surface.dart';
import '../quick_action.dart';
import 'element_decorator.dart';

class CardQuickActionDecorator implements ElementDecorator<QuickAction> {
  const CardQuickActionDecorator();
  @override
  Widget decorateDragged(BuildContext context, QuickAction element, Widget child, double opacity) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(blurRadius: 8, spreadRadius: -2, color: Colors.black.withOpacity(opacity * 0.5))],
      ),
      child: child,
    );
  }

  @override
  Widget decorateElement(BuildContext context, QuickAction element, Widget child) {
    return actionLayout(context, element);
  }

  @override
  Widget decoratePlaceholder(BuildContext context, QuickAction element) {
    return actionLayout(context, element, isPlaceholder: true);
  }

  Widget actionLayout(BuildContext context, QuickAction element, {bool isPlaceholder = false}) {
    return AspectRatio(
      aspectRatio: 1,
      child: ThemedSurface(
        preference: const ColorPreference(useHighlightColor: true),
        builder: (context, fillColor) => DecoratedBox(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), boxShadow: [
            BoxShadow(color: context.onSurfaceColor, blurRadius: 20, spreadRadius: -15),
          ]),
          child: Material(
            textStyle: TextStyle(color: context.onSurfaceColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: fillColor.withOpacity(isPlaceholder ? 0.8 : 1),
            child: isPlaceholder
                ? Container()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(element.icon, color: context.onSurfaceColor),
                      const SizedBox(height: 8),
                      Text(
                        element.text,
                        style: context.theme.textTheme.bodyText1!.apply(color: context.onSurfaceColor),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
