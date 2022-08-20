import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:papiana/src/models/conflicts.dart';
import 'package:papiana/src/models/implements.dart';
import 'package:papiana/src/services/package_analyzer.dart';

class PublicApiAnalyzer {
  final Iterable<ClassElement> source;
  final Iterable<ClassElement> target;

  final Completer<Iterable<Conflict>> _completer = Completer();
  bool _isStarted = false;

  PublicApiAnalyzer({required this.source, required this.target});

  static Future<PublicApiAnalyzer> fromPackageAnalyzers(
      {required PackageAnalyzer source, required PackageAnalyzer target}) async {
    await Future.wait([source.analyze(), target.analyze()]);
    return PublicApiAnalyzer(source: await source.results, target: await target.results);
  }

  Future<Iterable<Conflict>> get results async {
    if (!_isStarted) {
      _isStarted = true;
      analyze();
    }
    return _completer.future;
  }

  Future<Iterable<Conflict>> analyze() async {
    if (_completer.isCompleted) return _completer.future;

    List<Conflict> conflicts = [];

    for (ClassElement latestClass in source) {
      Iterable<ClassElement> matchingClasses = target.where((element) => latestClass.name == element.name);

      if (matchingClasses.length != 1) {
        if (matchingClasses.isEmpty) {
          conflicts.add(MissingClassConflict(latestClass));
        } else {
          conflicts.add(DuplicateClassConflict(latestClass));
        }
        continue;
      }

      ClassElement nextClass = matchingClasses.single;

      ImplementationResult result = nextClass.implementsClass(latestClass);

      if (result is ImplementationConflict) {
        conflicts.add(result);
      }
    }

    _completer.complete(conflicts);
    return conflicts;
  }
}
