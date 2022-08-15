import 'dart:io';

import 'package:args/args.dart';
import 'package:pana/pana.dart';
import 'package:papiana/src/api_analyzer.dart';
import 'package:papiana/src/models.dart';
import 'package:papiana/src/util/parse_pubspec.dart';
import 'package:papiana/src/util/build_path.dart';
import 'package:chalk/chalk.dart';

class Runner {
  final ArgParser _argParser = ArgParser();
  late ArgResults _argResults;

  Runner(Iterable<String> argv) {
    _argParser.addOption(
      'hosted-url',
      help: 'The server that hosts the package.',
      defaultsTo: 'https://pub.dev',
    );

    _argParser.addOption(
      'version',
      help: 'The hosted package version to compare to.',
      defaultsTo: 'latest',
    );

    _argParser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Increase verbosity',
      defaultsTo: false,
    );
    _argResults = _argParser.parse(argv);
  }

  Future<void> start() async {
    String packagePath = buildPath(_argResults.rest.first);
    Pubspec pubspec = await parsePubspec(packagePath);
    String? version = _argResults.wasParsed('version') ? _argResults['version'] : null;
    String? hostedUrl =
        _argResults.wasParsed('hosted-url') ? _argResults['hosted-url'] : pubspec.originalYaml['publish_to'];
    bool verbose = _argResults['verbose'] ?? true;

    late Iterable<Conflict> conflicts;

    try {
      conflicts = await ApiAnalyzer(
        packagePath,
        pubspec,
        version: version,
        hostedUrl: hostedUrl,
      ).analyze();
    } on Exception catch (e) {
      print(chalk.red(e.toString()));
      exit(1);
    }

    if (conflicts.isEmpty) {
      stdout.writeln('No conflicts detected');
      exit(0);
    }

    stdout.writeln('${conflicts.length} conflicts detected:');

    List<String> conflictLines = [];

    for (var outer in conflicts) {
      conflictLines.add('\t${outer.message}');

      if (outer is ImplementationConflict) {
        for (var inner in outer.conflicts) {
          conflictLines.add('\t\t${inner.message}');
        }
      }
    }

    stdout.writeAll(conflictLines, '\n');
    stdout.writeln();

    exit(0);
  }
}
