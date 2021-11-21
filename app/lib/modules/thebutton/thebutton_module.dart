import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_context/riverpod_context.dart';

import '../../../core/core.dart';
import '../../providers/trips/selected_trip_provider.dart';
import 'pages/thebutton_help.dart';
import 'pages/thebutton_settings.dart';
import 'widgets/thebutton_widget.dart';

class TheButtonModule extends ModuleBuilder<ContentSegment> {
  @override
  FutureOr<ContentSegment?> build(ModuleContext context) {
    var buttonHelpKey = GlobalKey();
    var buttonSettingsKey = GlobalKey();
    return ContentSegment(
      context: context,
      builder: (context) => Stack(
        children: [
          const Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: TheButton(),
            ),
          ),
          if (context.read(isOrganizerProvider)) Positioned.fill(child: TheButtonSettings(key: buttonSettingsKey)),
          Positioned.fill(child: TheButtonHelp(key: buttonHelpKey)),
        ],
      ),
    );
  }
}
