import 'dart:io';

import 'package:flutter_launcher_icons/main.dart' as flutter_icon_launcher;
import 'package:flutter_gen_core/flutter_generator.dart' as flutter_gen_core;
import 'package:interact/interact.dart';

void runAssetsCli() {
  final pick = Select(
    prompt: 'What would you like to do?',
    options: [
      Options.generateLauncherIcons,
      Options.generateAssets,
    ],
  ).interact();

  switch (pick) {
    case 0:
      generateAssets();
      break;
    case 1:
      generateLauncherIcons();
      break;
  }
}

class Options {
  static const generateLauncherIcons = 'Generate launcher icons';
  static const generateAssets = 'Generate assets';
}

void generateLauncherIcons() {
  flutter_icon_launcher.createIconsFromConfig({
    'android': true,
    'ios': true,
    'image_path_android': 'assets/launcher_icons/android.png',
    'image_path_ios': 'assets/launcher_icons/ios.png',
  });
}

void generateAssets() {
  flutter_gen_core.FlutterGenerator(File('pubspec.yaml')).build();
}
