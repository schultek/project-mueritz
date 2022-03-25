import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_context/riverpod_context.dart';

import '../../../helpers/extensions.dart';
import '../notes_provider.dart';
import '../pages/edit_note_page.dart';
import 'folder_dialog.dart';

class NotesList extends StatelessWidget {
  const NotesList({this.showTitle = false, Key? key}) : super(key: key);

  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    var notes = context.watch(notesProvider).value ?? [];
    var folders = notes.groupListsBy((n) => n.folder);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 20),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          if (showTitle)
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16.0, bottom: 20),
              child: Text(context.tr.notes, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          for (var note in folders[null] ?? <Note>[])
            ListTile(
              title: Text(note.title ?? 'Untitled'),
              subtitle: (() {
                var text = (note.content.isEmpty ? Document() : Document.fromJson(note.content))
                    .toPlainText()
                    .replaceAll('\n', ' ')
                    .trim();
                return text.isNotEmpty
                    ? Text(
                        text,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null;
              })(),
              leading: const Icon(Icons.sticky_note_2_outlined),
              minLeadingWidth: 20,
              onTap: () {
                Navigator.of(context).push(EditNotePage.route(note));
              },
            ),
          for (var folder in folders.keys)
            if (folder != null)
              ListTile(
                title: Text(folder),
                leading: const Icon(Icons.folder_outlined),
                minLeadingWidth: 20,
                onTap: () {
                  FolderDialog.show(context, folder);
                },
              ),
          ListTile(
            title: Text(context.tr.add),
            leading: const Icon(Icons.add),
            minLeadingWidth: 20,
            onTap: () {
              var note = context.read(notesLogicProvider).createEmptyNote();
              Navigator.of(context).push(EditNotePage.route(note));
            },
          ),
        ]
            .intersperse(const Divider(
              height: 0,
            ))
            .toList(),
      ),
    );
  }
}
