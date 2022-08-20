part of '../implements.dart';

const bool _publicOnlyDefault = true;
const bool _strictDefault = true;

extension ImplementsClass on ClassElement {
  ImplementationResult implementsClass(
    ClassElement other, {
    bool publicOnly = _publicOnlyDefault,
    bool strict = _strictDefault,
  }) {
    List<InterfaceConflict> conflicts = [];

    conflicts.addAll(_verifyFieldsAndMethods(other, publicOnly: publicOnly, strict: strict));
    conflicts.addAll(_verifyConstructors(other, publicOnly: publicOnly, strict: strict));

    if (conflicts.isEmpty) return SuccessfulImplementation();
    return ImplementationConflict(other, conflicts: conflicts);
  }

  List<InterfaceConflict> _verifyFieldsAndMethods(
    ClassElement other, {
    bool publicOnly = _publicOnlyDefault,
    bool strict = _strictDefault,
  }) {
    List<InterfaceConflict> conflicts = [];

    Map<Name, ExecutableElement> expected = InheritanceManager3().getInterface(other).map;
    Map<Name, ExecutableElement> actual = InheritanceManager3().getInterface(this).map;

    for (var name in expected.keys) {
      if (name.name == '') stdout.writeln('Unnamed');

      if (publicOnly && !name.isPublic) continue;

      if (actual[name] == null) {
        conflicts.add(MissingElementConflict(expected[name]!));
        continue;
      }

      ImplementationResult result = actual[name]!.implementsElement(expected[name]!, strict: strict);
      if (result is ImplementationConflict) conflicts.addAll(result.conflicts);
    }

    return conflicts;
  }

  List<InterfaceConflict> _verifyConstructors(
    ClassElement other, {
    bool publicOnly = _publicOnlyDefault,
    bool strict = _strictDefault,
  }) {
    List<InterfaceConflict> conflicts = [];
    for (var expected in other.constructors) {
      if (publicOnly && !expected.isPublic) continue;

      var matches = constructors.where((element) => element.name == expected.name);
      if (matches.length != 1) {
        if (matches.isEmpty) {
          conflicts.add(MissingElementConflict(expected));
        }
        if (matches.length > 1) {
          conflicts.add(DuplicateElementConflict(expected));
        }
        continue;
      }

      ConstructorElement actual = matches.single;

      ImplementationResult result = actual.implementsElement(expected, strict: strict);
      if (result is ImplementationConflict) conflicts.addAll(result.conflicts);
    }

    return conflicts;
  }
}
