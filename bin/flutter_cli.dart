import 'dart:io';

import 'package:interact/interact.dart';

import 'menus/assets.dart';
import 'menus/emulator.dart';
import 'menus/firebase.dart';
import 'menus/tests.dart';

void main(List<String> arguments) async {
  await showMainMenu();
}

Future<void> showMainMenu() async {
  final picked = Select(
    prompt: 'What is the task you would like to accomplish related with ?',
    options: Options.values.map((opt) => opt.name).toList(),
  ).interact();

  switch (Options.values[picked]) {
    case Options.assets:
      await runAssetsCli();
      break;
    case Options.emulators:
      await runEmulatorCli();
      break;
    case Options.tests:
      await runTestCli();
      break;
    case Options.firebase:
      await runFirebaseCli();
      break;
  }
  showMainMenu();
}

enum Options { assets, emulators, tests, firebase }
