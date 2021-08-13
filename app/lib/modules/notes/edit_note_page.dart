import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/areas/areas.dart';
import '../../core/module/module.dart' hide Brightness;
import '../../providers/auth/user_provider.dart';
import 'note_info_page.dart';
import 'notes_provider.dart';

class EditNotePage extends StatefulWidget {
  final Note note;
  final WidgetAreaState? area;
  const EditNotePage(this.note, {this.area, Key? key}) : super(key: key);

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late final QuillController _controller;
  final editorFocusNode = FocusNode();
  final editorFocusListenable = ValueNotifier(false);
  String? _title;

  bool get isEditor => widget.note.editors.contains(context.read(userIdProvider));
  bool get isAuthor => widget.note.author == context.read(userIdProvider);

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: widget.note.content.isEmpty ? Document() : Document.fromJson(widget.note.content),
      selection: const TextSelection.collapsed(offset: 0),
    );
    editorFocusNode.addListener(() {
      editorFocusListenable.value = editorFocusNode.hasPrimaryFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (isAuthor)
            IconButton(
              onPressed: () async {
                var nav = Navigator.of(context);
                var wasDeleted = await nav.push<bool>(NoteInfoPage.route(widget.note));
                if (wasDeleted == true) {
                  widget.area?.removeWidgetWithId(widget.note.id);
                  nav.pop();
                }
              },
              icon: const Icon(Icons.info),
            ),
          if (isEditor)
            IconButton(
              onPressed: () {
                var content = _controller.document.toDelta().toJson();
                context
                    .read(notesLogicProvider)
                    .updateNote(widget.note.id, widget.note.copyWith(title: _title, content: content));
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      body: TripTheme.of(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Builder(
              builder: (context) => Expanded(
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextFormField(
                        decoration: const InputDecoration(hintText: "Title"),
                        style: TextStyle(fontSize: 30, color: context.getTextColor()),
                        initialValue: widget.note.title,
                        onChanged: (text) => _title = text,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => editorFocusNode.requestFocus(),
                        readOnly: !isEditor,
                      ),
                    ),
                    QuillEditor(
                      controller: _controller,
                      scrollController: ScrollController(),
                      scrollable: false,
                      focusNode: editorFocusNode,
                      autoFocus: false,
                      readOnly: !isEditor,
                      expands: false,
                      padding: const EdgeInsets.all(20.0),
                      keyboardAppearance: Brightness.dark,
                    ),
                  ],
                ),
              ),
            ),
            if (isEditor)
              ValueListenableBuilder<bool>(
                valueListenable: editorFocusListenable,
                builder: (context, value, _) {
                  if (value) {
                    return FillColor(
                      builder: (context, fillColor) => Container(
                        color: fillColor,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          scrollDirection: Axis.horizontal,
                          child: QuillToolbar.basic(controller: _controller),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
