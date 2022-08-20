import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:papiana/src/models/exceptions.dart';
import 'package:papiana/src/models/package_source.dart';
import 'package:papiana/src/services/element_collector.dart';
import 'package:papiana/src/util/path_util.dart';
import 'package:path/path.dart' as p;

class PackageAnalyzer {
  final ElementCollector collector = ElementCollector();
  final Completer<Iterable<ClassElement>> _completer = Completer();
  bool _isStarted = false;

  final PackageSource packageSource;
  final bool pub;

  PackageAnalyzer(this.packageSource, {this.pub = true});

  Future<Iterable<ClassElement>> get results async {
    if (!_isStarted) {
      _isStarted = true;
      analyze();
    }
    return _completer.future;
  }

  Future<Iterable<ClassElement>> analyze() async {
    if(_completer.isCompleted) return _completer.future;

    String packagePath = await packageSource.packagePath;

    if (pub) {
      ProcessResult result = await Process.run(
        'dart',
        ['pub', 'get'],
        workingDirectory: packagePath,
        runInShell: true,
      );

      if (result.exitCode != 0) throw PubGetException(result);
    }

    final contextCollection = AnalysisContextCollection(
      includedPaths: [
        buildPath(packagePath, 'lib'),
      ],
    );

    final dartFiles = Directory(
      buildPath(packagePath, 'lib'),
    ).listSync(recursive: false).where((file) => p.extension(file.path) == '.dart');

    final collector = ElementCollector();

    for (final file in dartFiles) {
      final filePath = buildPath(file.path);
      final context = contextCollection.contextFor(filePath);
      final unitResult = await context.currentSession.getResolvedUnit(filePath);

      if (unitResult is! ResolvedUnitResult) continue;
      if (unitResult.isPart) continue;
      unitResult.libraryElement.accept(collector);
    }

    _completer.complete(collector.classElements);
    return collector.classElements;
  }
}
