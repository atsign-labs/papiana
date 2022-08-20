import 'package:papiana/papiana.dart';
import 'package:papiana/src/util/path_util.dart';
import 'package:papiana/src/util/print_conflicts.dart';
import 'package:test/test.dart';

import 'test_util/test_directory.dart';

void main() {
  late Iterable<Conflict> conflicts;

  setUpAll(() async {
    PackageAnalyzer source = PackageAnalyzer(LocalPackageSource(buildPath(testDirectory, 'removed', 'source')));
    PackageAnalyzer target = PackageAnalyzer(LocalPackageSource(buildPath(testDirectory, 'removed', 'target')));

    PublicApiAnalyzer analyzer = await PublicApiAnalyzer.fromPackageAnalyzers(source: source, target: target);
    conflicts = await analyzer.results;

    printConflicts(conflicts);
  });

  test('class', () {
    expect(
      conflicts,
      contains(
        allOf(
          isA<MissingClassConflict>(),
          (element) => element.expected.name == 'MyClass',
        ),
      ),
    );
  });

  group('constructors -', () {
    // test('empty unnamed constructor', () { 
    //   expect(conflicts, contains(isA<ImplementationConflict>()));
    //   expect(
    //     (conflicts.singleWhere((element) => element is ImplementationConflict) as ImplementationConflict).conflicts,
    //     contains(
    //       allOf(
    //         isA<MissingElementConflict>(),
    //         (element) => element.expected.name == '',
    //         (element) => element.expected is ConstructorElement,
    //       ),
    //     ),
    //   );
    // });

    test('named constructor', () {
      expect(conflicts, contains(isA<ImplementationConflict>()));
      expect(
        (conflicts.singleWhere((element) => element is ImplementationConflict) as ImplementationConflict).conflicts,
        contains(
          allOf(
            isA<MissingElementConflict>(),
            (element) => element.expected.name == 'myConstructor',
            (element) => element.expected is ConstructorElement,
          ),
        ),
      );
    });

    test('named factory', () {
      expect(conflicts, contains(isA<ImplementationConflict>()));
      expect(
        (conflicts.singleWhere((element) => element is ImplementationConflict) as ImplementationConflict).conflicts,
        contains(
          allOf(
            isA<MissingElementConflict>(),
            (element) => element.expected.name == 'factoryFunction',
            (element) => element.expected is ConstructorElement,
          ),
        ),
      );
    });
  });

  group('instance -', () {
    test('method', () {
      expect(conflicts, contains(isA<ImplementationConflict>()));
      expect(
        (conflicts.singleWhere((element) => element is ImplementationConflict) as ImplementationConflict).conflicts,
        contains(
          allOf(
            isA<MissingElementConflict>(),
            (element) => element.expected.name == 'myFunc',
            (element) => element.expected is ExecutableElement,
          ),
        ),
      );
    });

    test('field', () {
      expect(conflicts, contains(isA<ImplementationConflict>()));
      expect(
        (conflicts.singleWhere((element) => element is ImplementationConflict) as ImplementationConflict).conflicts,
        containsAll([
          allOf(
            isA<MissingElementConflict>(),
            (element) => element.expected.name == 'hello',
            (element) => element.expected is ExecutableElement,
            (element) =>
                (element.expected as ExecutableElement).returnType.getDisplayString(withNullability: true) == 'String',
          ),
          allOf(
            isA<MissingElementConflict>(),
            (element) => element.expected.name == 'hello=',
            (element) => element.expected is ExecutableElement,
            (element) => (element.expected as ExecutableElement).parameters.length == 1,
            (element) =>
                (element.expected as ExecutableElement)
                    .parameters
                    .single
                    .type
                    .getDisplayString(withNullability: true) ==
                'String',
          ),
        ]),
      );
    });

    test('getter', () {
      expect(conflicts, contains(isA<ImplementationConflict>()));
      expect(
        (conflicts.singleWhere((element) => element is ImplementationConflict) as ImplementationConflict).conflicts,
        contains(
          allOf(
            isA<MissingElementConflict>(),
            (element) => element.expected.name == 'world',
            (element) => element.expected is ExecutableElement,
            (element) =>
                (element.expected as ExecutableElement).returnType.getDisplayString(withNullability: true) == 'String',
          ),
        ),
      );
    });

    test('setter', () {
      expect(conflicts, contains(isA<ImplementationConflict>()));
      expect(
        (conflicts.singleWhere((element) => element is ImplementationConflict) as ImplementationConflict).conflicts,
        contains(
          allOf(
            isA<MissingElementConflict>(),
            (element) => element.expected.name == 'world=',
            (element) => element.expected is ExecutableElement,
            (element) => (element.expected as ExecutableElement).parameters.length == 1,
            (element) =>
                (element.expected as ExecutableElement)
                    .parameters
                    .single
                    .type
                    .getDisplayString(withNullability: true) ==
                'String',
          ),
        ),
      );
    });
  });

  group('static -', () {
    // test('method', () {});
    // test('field', () {});
    // test('getter', () {});
    // test('setter', () {});
  });
}
