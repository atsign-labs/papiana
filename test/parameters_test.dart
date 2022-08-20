import 'package:papiana/papiana.dart';
import 'package:papiana/src/util/path_util.dart';
import 'package:test/test.dart';

import 'test_util/test_directory.dart';

void main() {
  late Iterable<Conflict> conflicts;

  setUpAll(() async {
    PackageAnalyzer source = PackageAnalyzer(LocalPackageSource(buildPath(testDirectory, 'parameters', 'source')));
    PackageAnalyzer target = PackageAnalyzer(LocalPackageSource(buildPath(testDirectory, 'parameters', 'target')));

    PublicApiAnalyzer analyzer = await PublicApiAnalyzer.fromPackageAnalyzers(source: source, target: target);
    conflicts = await analyzer.results;
  });
}
