import 'dart:io';

// import 'package:dcli/dcli.dart';
import 'package:dcli/dcli.dart';
import 'package:interact/interact.dart';
import 'package:path/path.dart' as path;

const testDir = 'test';
final unitTestDir = path.join(testDir, 'unit');
final integrationTestDir = path.join(testDir, 'integration');
final driverPath = path.join(testDir, 'driver', 'integration_test_driver.dart');
final testFileRegExp = RegExp(r'_test.dart$');

enum Options { unit, integration }
enum Platform { web, android }

Future<dynamic> runTestCli() async {
  final picked = Select(
    prompt: 'What kind of test would you like to run ?',
    options: Options.values.map((option) => option.name).toList(),
  ).interact();

  switch (Options.values[picked]) {
    case Options.unit:
      final file = await showFilePicker(unitTestDir);
      return runUnitTests(file);
    case Options.integration:
      await _createDriverIfNotExist();
      final file = await showFilePicker(integrationTestDir);
      final platform = showPlatformPicker();
      if (platform == Platform.web) {
        return runIntegrationTests(file, device: 'web-server');
      }
      final device = await showDevicePicker();
      return runIntegrationTests(file, device: device);
  }
}

Future<String> showFilePicker(String directory) async {
  final allTestPaths = await _findTestPaths(directory);

  if (allTestPaths.isEmpty) {
    print('No test found under $directory');
    exit(1);
  }

  final picked = Select(
    prompt: 'Which test would you like to run ?',
    options: [
      'all',
      ...allTestPaths.map((filePath) => path.split(filePath).last),
    ],
  ).interact();

  if (picked == 0) {
    return directory;
  } else {
    return allTestPaths[picked - 1];
  }
}

Future<List<String>> _findTestPaths(String path) async {
  List<FileSystemEntity> allFiles = [];

  try {
    allFiles = await Directory(path).list(recursive: true).toList();
  } on FileSystemException {
    print('The directory $path could not be found');
    exit(2);
  }
  final allTestFiles =
      allFiles.where((file) => testFileRegExp.hasMatch(file.path)).toList();
  return allTestFiles.map((file) => file.path).toList();
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

Future<dynamic> runIntegrationTests(
  String path, {
  required String device,
}) async {
  final flutter = which('flutter');
  if (flutter.notfound) {
    print('flutter was not found in the path');
    exit(2);
  }
  final isDirectory = await Directory(path).exists();
  List<String> allTestFiles;
  if (isDirectory) {
    allTestFiles = await _findTestPaths(path);
  } else {
    allTestFiles = [path];
  }

  for (final file in allTestFiles) {
    final process = await Process.start(
      'flutter',
      [
        'driver',
        '--driver=$driverPath',
        '--target=$file',
        '--no-pub',
        '-d',
        device,
      ],
      mode: ProcessStartMode.inheritStdio,
      runInShell: true,
    );
    await process.exitCode;
  }
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
