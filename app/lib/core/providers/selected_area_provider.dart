import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'editing_providers.dart';

final selectedAreaProvider = StateNotifierProvider<SelectArea, String?>((ref) => SelectArea(ref));

final isAreaSelectedProvider =
    Provider.family((ref, String id) => ref.watch(selectedAreaProvider.select((area) => area == id)));

class SelectArea extends StateNotifier<String?> {
  SelectArea(this.ref) : super(null) {
    ref.listen<bool>(editProvider, (_, editState) {
      if (!editState && state != null) {
        _unselectArea();
      }
    });
  }

  final Ref ref;

  void selectWidgetAreaById(String? id) async {
    if (!ref.read(editProvider)) return;
    if (super.state == id) return;
    super.state = id;
  }

  void _unselectArea() {
    super.state = null;
  }

  @override
  set state(String? value) {
    throw UnsupportedError('Do not set selected area directly');
  }
}
