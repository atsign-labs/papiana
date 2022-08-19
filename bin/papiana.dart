import 'dart:io';

import 'package:papiana/src/runner.dart';

Future<void> main(List<String> args) async {
  exit(await Runner().run(args));
}
