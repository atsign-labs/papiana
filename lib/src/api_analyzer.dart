import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:pana/pana.dart' show downloadPackage, Pubspec;
import 'package:papiana/src/models.dart';
import 'package:papiana/src/exceptions.dart';
import 'package:papiana/src/implements.dart';
import 'package:papiana/src/package_analyzer.dart';
import 'package:papiana/src/util/build_path.dart';

class ApiAnalyzer {
  final String packagePath;
  final Pubspec pubspec;
  final String? version;
  final String? hostedUrl;

  final Completer<Iterable<Conflict>> _completer = Completer();

  ApiAnalyzer(this.packagePath, this.pubspec, {this.version, this.hostedUrl});

  Future<Iterable<Conflict>> get results async {
    return _completer.future;
  }

  Future<Iterable<Conflict>> analyze() async {
    List<Conflict> conflicts = [];

    String remotePackagePath = buildPath(packagePath, '.dart_tool', 'papiana', pubspec.name);

    PackageAnalyzer nextAnalyzer = PackageAnalyzer(packagePath)..analyze();
    PackageAnalyzer latestAnalyzer = PackageAnalyzer(remotePackagePath);

    await nextAnalyzer.results;

    try {
      await downloadPackage(
        pubspec.name,
        version,
        destination: remotePackagePath,
        pubHostedUrl: hostedUrl,
      );
    } catch (e) {
      throw PackageDownloadException(pubspec.name, version: version);
    }

    ProcessResult result = await Process.run(
      'dart',
      ['pub', 'get'],
      workingDirectory: remotePackagePath,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      throw PubGetException();
    }

    List<Iterable<ClassElement>> elements = await Future.wait([
      nextAnalyzer.results,
      latestAnalyzer.analyze(),
    ]);

    Iterable<ClassElement> nextElements = elements[0];
    Iterable<ClassElement> latestElements = elements[1];

    for (ClassElement latestClass in latestElements) {
      Iterable<ClassElement> matchingClasses = nextElements.where((element) => latestClass.name == element.name);

      if (matchingClasses.length != 1) {
        if (matchingClasses.isEmpty) {
          conflicts.add(MissingClassConflict(latestClass.name));
        } else {
          conflicts.add(DuplicateClassConflict(latestClass.name, matchingClasses.length));
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
