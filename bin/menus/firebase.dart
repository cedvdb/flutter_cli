import 'dart:io';

import 'package:interact/interact.dart';

const _firebaseDir = 'firebase';

Future<void> runFirebaseCli() async {
  final pick = Select(prompt: 'What would you like to do ?', options: [
    Options.configureFirebase,
    Options.configureFlutterFire,
    Options.runFirebaseEmulator,
  ]).interact();
  switch (pick) {
    case 0:
      await createFirebaseDirectory();
      await runFirebaseInit();
      break;
    case 1:
      runFlutterFireConfigure();
      break;
    case 2:
      await runFirebaseEmulator();
      break;
  }
}

class Options {
  static const configureFirebase = 'Configure Firebase';
  static const configureFlutterFire = 'Configure FlutterFire';
  static const runFirebaseEmulator = 'Run Firebase emulator';
}

Future<void> createFirebaseDirectory() async {
  final isFirebaseDirPresent = await Directory(_firebaseDir).exists();

  if (!isFirebaseDirPresent) {
    Directory(_firebaseDir).create();
  } else {
    final isReplaceConfirmed = Confirm(
      prompt: 'firebase directory already exists, do you want to replace it ?',
    ).interact();
    if (isReplaceConfirmed) {
      await Directory(_firebaseDir).delete(recursive: true);
      await Directory(_firebaseDir).create();
    } else {
      print('firebase directory already exist, cannot go further.');
      exit(2);
    }
  }
}

Future<Process> runFirebaseInit() {
  return Process.start(
    'firebase',
    ['init'],
    workingDirectory: 'firebase',
    mode: ProcessStartMode.inheritStdio,
    runInShell: true,
  );
}

Future<Process> runFlutterFireConfigure() async {
  return Process.start(
    'dart run flutterfire_cli:flutterfire',
    ['configure'],
    workingDirectory: 'firebase',
    mode: ProcessStartMode.inheritStdio,
    runInShell: true,
  );
}

Future<Process> runFirebaseEmulator() {
  return Process.start(
    'firebase',
    ['emulators:start'],
    workingDirectory: 'firebase',
    mode: ProcessStartMode.inheritStdio,
    runInShell: true,
  );
}
