import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:papiana/src/collector.dart';
import 'package:papiana/src/util/build_path.dart';
import 'package:path/path.dart' as p;

class PackageAnalyzer {
  final Collector collector = Collector();
  final String packagePath;

  final Completer<Iterable<ClassElement>> _completer = Completer();

  PackageAnalyzer(this.packagePath);

  Future<Iterable<ClassElement>> get results async {
    return _completer.future;
  }

  Future<Iterable<ClassElement>> analyze() async {

    final contextCollection = AnalysisContextCollection(
      includedPaths: [
        buildPath(packagePath, 'lib'),
      ],
    );

    final dartFiles = Directory(
      buildPath(packagePath, 'lib'),
    ).listSync(recursive: false).where((file) => p.extension(file.path) == '.dart');

    final collector = Collector();

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
