import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_context/riverpod_context.dart';

import '../../core/core.dart';
import '../../core/widgets/widget_selector.dart';
import '../../providers/notifications/notifications_provider.dart';
import 'pages/channel_page.dart';
import 'pages/chat_page.dart';
import 'widgets/channel_list.dart';

class ChatModule extends ModuleBuilder<PageSegment> {
  ChatModule() : super('chat');

  @override
  Map<String, ElementBuilder<ModuleElement>> get elements => {
        'channels': buildPageSegment,
        'action': buildAction,
      };

  FutureOr<PageSegment?> buildPageSegment(ModuleContext context) {
    return PageSegment(
      context: context,
      builder: (context) {
        if (WidgetSelector.existsIn(context)) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: context.onSurfaceColor,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.chat, size: MediaQuery.of(context).size.width / 2),
          );
        }
        return const ChannelList();
      },
    );
  }

  FutureOr<QuickAction?> buildAction(ModuleContext context) {
    return QuickAction(
      context: context,
      icon: Icons.chat,
      text: 'Chat',
      onNavigate: (context) => const ChatPage(),
    );
  }

  static StreamSubscription<RemoteMessage?>? _msgSub;

  @override
  Iterable<Route> generateInitialRoutes(BuildContext context) sync* {
    var message = context.read(messageProvider);
    if (message?.data['channelId'] != null) {
      yield ChannelPage.route(message!.data['channelId'] as String);
    }
  }

  @override
  void preload(BuildContext context) {
    _msgSub?.cancel();
    _msgSub = context.read(messageProvider.state).stream.listen((m) {
      if (m?.data['channelId'] != null) {
        Navigator.of(context).push(ChannelPage.route(m!.data['channelId'] as String));
      }
    });
    print('Subscribed to messages');
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose();
  }
}
