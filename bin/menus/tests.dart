import 'dart:io';

// import 'package:dcli/dcli.dart';
import 'package:dcli/dcli.dart';
import 'package:interact/interact.dart';
import 'package:path/path.dart' as path;

const testDir = 'test';
final unitTestDir = path.join(testDir, 'unit');
final integrationTestDir = path.join(testDir, 'integration');
final driverPath = path.join(testDir, 'driver', 'integration_test_driver.dart');
final testRegExp = RegExp(r'_test.dart$');

enum Options { unit, integration }
enum Platform { web, android }

void runTestCli() async {
  final picked = Select(
    prompt: 'What kind of test would you like to run ?',
    options: Options.values.map((option) => option.name).toList(),
  ).interact();

  switch (Options.values[picked]) {
    case Options.unit:
      final file = await showFilePicker(unitTestDir);
      await runUnitTests(file);
      break;
    case Options.integration:
      _createDriverIfNotExist();
      final file = await showFilePicker(integrationTestDir);
      final device = await showDevicePicker();
      await runIntegrationTests(file, device);
      break;
  }
}

Future<String> showFilePicker(String directory) async {
  await _createDriverIfNotExist();
  List<FileSystemEntity> allFiles = [];

  try {
    allFiles = await Directory(directory).list(recursive: true).toList();
  } on FileSystemException {
    print('The directory $directory could not be found');
    exit(2);
  }
  final allTestFiles =
      allFiles.where((file) => testRegExp.hasMatch(file.path)).toList();

  if (allTestFiles.isEmpty) {
    print('No test found under $directory');
    exit(1);
  }

  final picked = Select(
    prompt: 'Which test would you like to run ?',
    options: [
      'all',
      ...allTestFiles.map((file) => path.split(file.path).last),
    ],
  ).interact();

  if (picked == 0) {
    return integrationTestDir;
  } else {
    return allTestFiles[picked - 1].path;
  }
}

Platform showPlatformPicker() {
  final picked = Select(
    prompt: 'On what platform would you like to run the tests ?',
    options: Platform.values.map((platform) => platform.name).toList(),
  ).interact();
  return Platform.values[picked];
}

Future<String> showDevicePicker() async {
  final result = await Process.run('adb', ['devices']);
  // skip 1 because the first line of the output does not contain a device
  final lines = (result.stdout as String).split('\n').skip(1);
  final devices = lines
      .map((line) => line.trim().split(RegExp(r'\s+')).first)
      .where((device) => device.isNotEmpty)
      .map((device) => device.trim())
      .toList();
  if (devices.isEmpty) {
    print('No active device found, connect one or start an emulator first.');
    exit(1);
  }
  if (devices.length == 1) {
    return devices.first;
  }
  final picked = Select(
    prompt: 'On what device would you like to run',
    options: devices,
  ).interact();
  return devices[picked];
}

Future<Process> runUnitTests(String path) async {
  return Process.start(
    'flutter',
    [
      'test',
      path,
    ],
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
}

Future<Process> runIntegrationTests(String path, String device) {
  final flutter = which('flutter');
  if (flutter.notfound) {
    print('flutter was not found in the path');
    exit(2);
  }
  return Process.start(
    flutter.path!,
    ['driver', '--driver=$driverPath', '--target=$path', '-d', device],
    mode: ProcessStartMode.inheritStdio,
  );
}

Future<void> _createDriverIfNotExist() async {
  final isDriverFound = await File(driverPath).exists();
  if (!isDriverFound) {
    await _createDriver();
  }
}

Future<void> _createDriver() async {
  final driver = await File(driverPath).create(recursive: true);
  await driver.writeAsString(
    '''
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  return integrationDriver();
}
''',
  );
}
