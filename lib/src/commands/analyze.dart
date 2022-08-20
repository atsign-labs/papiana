import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chalk/chalk.dart';
import 'package:papiana/src/models/conflicts.dart';
import 'package:papiana/src/models/package_source.dart';
import 'package:papiana/src/services/package_analyzer.dart';
import 'package:papiana/src/services/public_api_analyzer.dart';
import 'package:papiana/src/util/constants.dart';
import 'package:papiana/src/util/print_conflicts.dart';

const _name = 'analyze';
const _description = 'Analyze the given packages';

const String _source = 'source';
const String _target = 'target';

class AnalyzeCommand extends Command<int> {
  @override
  String get name => _name;

  @override
  String get description => _description;

  AnalyzeCommand() {
    argParser.addSeparator('Source (The expected Public API):');
    _addOptions(_source, abbr: 's');

    argParser.addSeparator('Target (The API being analyzed for breaking changes):');
    _addOptions(_target, abbr: 't');
  }

  void _addOptions(String name, {String? abbr}) {
    argParser.addOption(
      name,
      abbr: abbr,
      mandatory: true,
      help: 'The path / name of the $name package.',
    );
    argParser.addFlag(
      '$name-hosted',
      aliases: [if (abbr != null) '${abbr}h'],
      help: 'Whether to download the package from a hosted source.',
      negatable: false,
    );
    argParser.addOption(
      '$name-url',
      help: 'The hosted url of the $name package. (Only applies when $name-hosted is true).',
    );
    argParser.addOption(
      '$name-version',
      help: 'The version number of the $name package.',
    );
  }

  PackageSource _getPackageSource(String name) {
    String? package = argResults![name];

    if (package == null) throw UsageException('Missing required parameter: "$name".', usage);

    if (argResults!['$name-hosted'] ?? false) {
      return HostedPackageSource(
        package,
        version: argResults?['$name-version'],
        hostedUrl: argResults?['$name-url'] ?? defaultHostedUrl,
      );
    }

    return LocalPackageSource(package);
  }

  @override
  Future<int> run() async {
    PackageSource source = _getPackageSource(_source);
    PackageSource target = _getPackageSource(_target);

    Iterable<Conflict> conflicts = [];

    try {
      PublicApiAnalyzer analyzer = await PublicApiAnalyzer.fromPackageAnalyzers(
        source: PackageAnalyzer(source),
        target: PackageAnalyzer(target),
      );

      conflicts = await analyzer.results;
    } on Exception catch (e) {
      stdout.writeln(chalk.red(e.toString()));
      return 1;
    }

    if (conflicts.isEmpty) {
      stdout.writeln('No conflicts detected!');
    } else {
      printConflicts(conflicts);
    }

    return 0;
  }
}
