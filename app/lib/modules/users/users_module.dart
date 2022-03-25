import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../helpers/extensions.dart';
import '../../widgets/simple_card.dart';
import 'pages/users_page.dart';

class UsersModule extends ModuleBuilder {
  UsersModule() : super('users');

  @override
  String getName(BuildContext context) => context.tr.users;

  @override
  Map<String, ElementBuilder<ModuleElement>> get elements => {
        'users': buildUsers,
        'users_action': buildUsersAction,
      };

  @override
  ModuleSettings? getSettings(BuildContext context) {
    return ModuleSettings([
      ListTile(
        title: Text(context.tr.open_users),
        onTap: () => Navigator.of(context).push(UsersPage.route()),
      ),
    ]);
  }

  FutureOr<ContentSegment?> buildUsers(ModuleContext context) {
    return ContentSegment(
      context: context,
      builder: (context) => SimpleCard(title: context.tr.users, icon: Icons.supervised_user_circle),
      onNavigate: (context) => const UsersPage(),
    );
  }

  FutureOr<QuickAction?> buildUsersAction(ModuleContext context) {
    return QuickAction(
      context: context,
      icon: Icons.supervised_user_circle,
      text: context.context.tr.users,
      onNavigate: (context) => const UsersPage(),
    );
  }
}
