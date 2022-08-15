import 'dart:io';

import 'package:papiana/src/exceptions.dart';
import 'package:papiana/src/util/build_path.dart';
import 'package:pana/pana.dart';

const _fileName = 'pubspec.yaml';

Future<Pubspec> parsePubspec(String packagePath) async {
  File pubspecFile = File(buildPath(packagePath, _fileName));

  if (!await pubspecFile.exists()) {
    throw PubspecException();
  }

  return Pubspec.parseYaml(await pubspecFile.readAsString());
}
