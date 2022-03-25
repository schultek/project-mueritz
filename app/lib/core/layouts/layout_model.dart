import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_context/riverpod_context.dart';

import '../../providers/trips/logic_provider.dart';
import '../templates/template_model.dart';
import '../widgets/layout_preview.dart';
import 'drops_layout.dart';
import 'focus_layout.dart';
import 'full_page_layout.dart';
import 'grid_layout.dart';

@MappableClass(discriminatorKey: 'type')
abstract class LayoutModel {
  final String type;
  const LayoutModel(this.type);

  String get name;
  Widget builder(LayoutContext context);

  PreviewPage preview({Widget? header});

  static List<LayoutModel> get all => const [
        GridLayoutModel(),
        FullPageLayoutModel(),
        FocusLayoutModel(),
        DropsLayoutModel(),
      ];
}

class LayoutContext {
  final String id;
  final Widget? header;
  final BuildContext context;
  final TemplateModel Function(LayoutModel updated) onUpdate;

  LayoutContext({
    required this.id,
    this.header,
    required this.context,
    required this.onUpdate,
  });

  Future<void> update(LayoutModel updated) async {
    await context.read(tripsLogicProvider).updateTemplateModel(onUpdate(updated));
  }
}
