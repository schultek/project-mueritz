import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_context/riverpod_context.dart';

import '../../../core/core.dart';
import '../../../helpers/extensions.dart';
import '../../../widgets/user_avatar.dart';
import '../game_provider.dart';
import '../pages/game_page.dart';

class GamesList extends StatelessWidget {
  const GamesList({Key? key}) : super(key: key);

  static List<Widget> tilesBuilder(BuildContext context, [bool needsSurface = false]) {
    var games = context.watch(gamesProvider).value ?? [];
    games.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return [for (var game in games) GameTile(game, needsSurface: needsSurface)];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: tilesBuilder(context, true).intersperse(const SizedBox(height: 10)).toList(),
    );
  }
}

class GameTile extends StatelessWidget {
  final EliminationGame game;
  final bool needsSurface;
  const GameTile(this.game, {this.needsSurface = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (needsSurface) {
      return ThemedSurface(builder: (context, color) => buildTile(context, color));
    } else {
      return buildTile(context, null);
    }
  }

  Widget buildTile(BuildContext context, Color? tileColor) {
    var curTargets = game.currentTargets;

    var alivePlayers = curTargets.entries.where((e) => e.value != null && e.value != e.key);
    var immortalPlayers = curTargets.entries.where((e) => e.value == e.key);

    var labels = [
      if (immortalPlayers.isNotEmpty) 'Immortal',
      if (alivePlayers.isNotEmpty) 'Alive',
    ];

    return ListTile(
      tileColor: tileColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(game.name, style: TextStyle(color: context.onSurfaceColor)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              'Started ${game.startedAt.toDateString()}',
              style: context.theme.textTheme.caption!.copyWith(color: context.onSurfaceColor),
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Text(labels.join(' | '), style: TextStyle(color: context.onSurfaceColor)),
          const SizedBox(height: 5),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (var player in immortalPlayers) ...[
                  UserAvatar(id: player.key),
                  const SizedBox(width: 8),
                ],
                if (immortalPlayers.isNotEmpty && alivePlayers.isNotEmpty) ...[
                  const VerticalDivider(),
                  const SizedBox(width: 8),
                ],
                for (var player in alivePlayers) ...[
                  UserAvatar(id: player.key),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(GamePage.route(game.id));
      },
    );
  }
}