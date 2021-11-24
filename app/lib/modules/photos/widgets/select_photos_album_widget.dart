import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_context/riverpod_context.dart';

import '../../../core/core.dart';
import '../../../providers/trips/selected_trip_provider.dart';
import '../pages/select_photos_album_page.dart';
import '../providers/google_account_provider.dart';
import '../providers/photos_provider.dart';

class SelectPhotosAlbumWidget extends StatefulWidget {
  final IdProvider idProvider;
  const SelectPhotosAlbumWidget(this.idProvider, {Key? key}) : super(key: key);

  static FutureOr<ContentSegment?> segment(ModuleContext context) {
    if (!context.context.read(isOrganizerProvider)) {
      return null;
    }
    var idProvider = IdProvider();
    return ContentSegment(
      context: context,
      idProvider: idProvider,
      builder: (context) => SelectPhotosAlbumWidget(idProvider),
    );
  }

  @override
  State<SelectPhotosAlbumWidget> createState() => _SelectPhotosAlbumWidgetState();
}

class _SelectPhotosAlbumWidgetState extends State<SelectPhotosAlbumWidget> {
  Future<bool> showSignInWithGooglePrompt(BuildContext context) async {
    var didSignIn = await showPrompt<bool>(
      context,
      title: 'SignIn with Google',
      body: 'In order to use the shared photos album, you have to sign in with your google account.',
      onContinue: () => context.read(googleAccountProvider.notifier).signIn(),
    );
    return didSignIn ?? false;
  }

  Future<T?> showPrompt<T>(BuildContext context,
      {required String title, String? body, required FutureOr<T> Function() onContinue}) async {
    var result = await showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: body != null ? Text(body) : null,
        actions: [
          TextButton(
            onPressed: () async {
              var result = await onContinue();
              Navigator.of(context).pop(result);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return result;
  }

  void selectAlbum(BuildContext context) async {
    var isSignedIn = await context.read(isSignedInWithGoogleProvider.future);
    if (!isSignedIn) {
      isSignedIn = await showSignInWithGooglePrompt(context);
      if (!isSignedIn) return;
    }

    var albums = await context.read(photosLogicProvider).getAlbums();

    var selectedAlbum = await Navigator.of(context).push(SelectPhotosAlbumPage.route(albums));

    if (selectedAlbum != null) {
      var docId = await context.read(photosLogicProvider).createAlbumShortcut(selectedAlbum);
      widget.idProvider.provide(context, docId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        selectAlbum(context);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image,
                color: context.getTextColor(),
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                'Select Album',
                style: Theme.of(context).textTheme.headline6!.copyWith(color: context.getTextColor()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
