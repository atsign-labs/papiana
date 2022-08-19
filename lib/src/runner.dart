import 'dart:io';

import 'package:args/command_runner.dart' show CommandRunner, UsageException;
import 'package:chalk/chalk.dart';
import 'package:papiana/src/commands/analyze.dart';
import 'package:papiana/src/commands/cache.dart';

const String name = '';
const String description = '';

class Runner extends CommandRunner<int> {
  Runner() : super(name, description) {
    addCommand(AnalyzeCommand());
    addCommand(CacheCommand());
  }

  @override
  Future<int> run(Iterable<String> args) async {
    int result = 0;
    try {
      final argResults = parse(args);
      result = await runCommand(argResults) ?? 0;
    } on FormatException catch (e) {
      stdout.writeAll([chalk.red(e.message), usage]);
      result = 1;
    } on UsageException catch (e) {
      stdout.writeAll([chalk.red(e.message), e.usage]);
      result = 1;
    }

    return result;
  }
}
