import 'package:interact/interact.dart';
import 'package:flutter_flavorizr/flutter_flavorizr.dart' as flavorizr;

enum Option { create }

Future<dynamic> runFlavorsCli() async {
  final picked = pickOption();
  switch (picked) {
    case Option.create:
      // TODO: Handle this case.
      break;
  }
}

Option pickOption() {
  final picked = Select(
    prompt: 'What would you like to do ?',
    options: Option.values.map((option) => option.name).toList(),
  ).interact();
  return Option.values[picked];
}

Future runFlavorizr() {
  flavorizr.execute(args)
}
