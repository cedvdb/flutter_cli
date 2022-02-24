import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:interact/interact.dart';

enum Options { android, chromedriver }

Future<void> runEmulatorCli() async {
  final picked = Select(
    prompt: 'For which platform would you like to run an emulator ?',
    options: Options.values.map((option) => option.name).toList(),
  ).interact();

  switch (Options.values[picked]) {
    case Options.android:
      final device = await pickDevice();
      await runAndroidEmulator(device);
      break;
    case Options.chromedriver:
      await runChromeDriver();
      break;
  }
}

Future<String> pickDevice() async {
  final isEmulatorInstalled = which('emulator').found;
  if (!isEmulatorInstalled) {
    print('emulator not in the path, you can install it via android studio');
    exit(1);
  }

  final result = await Process.run('emulator', ['-list-avds']);
  final availableDevices = (result.stdout as String)
      .split("\n")
      .where((line) => line.isNotEmpty)
      .toList();
  if (availableDevices.isEmpty) {
    print(
      'There does not seem to be any emulator available, '
      'please install one via android studio and try again.',
    );
  }
  final picked = Select(
    prompt: 'Which emulator would you like to start ?',
    options: availableDevices,
  ).interact();
  return availableDevices.elementAt(picked);
}

Future<Process> runAndroidEmulator(String device) {
  return Process.start(
    'emulator',
    ['-avd', device],
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
}

Future<Process> runChromeDriver() {
  final isChromeDriverInstalled = which('chromedriver').found;
  if (!isChromeDriverInstalled) {
    print('chrome driver is not installed, it is required to run it. '
        'https://chromedriver.chromium.org/downloads');
    exit(1);
  }
  return Process.start(
    'chromedriver',
    ['--port=4444'],
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
}
