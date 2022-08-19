import 'package:papiana/papiana.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/inheritance_manager3.dart';
import 'package:papiana/src/models/conflicts.dart';

const bool _publicOnlyDefault = true;
const bool _strictModeDefault = true;

extension ImplementsClass on ClassElement {
  ImplementationResult implementsClass(
    ClassElement other, {
    bool publicOnly = _publicOnlyDefault,
    bool strict = _strictModeDefault,
  }) {
    List<InterfaceConflict> conflicts = [];

    conflicts.addAll(_verifyFieldsAndMethods(other, publicOnly: publicOnly, strict: strict));
    conflicts.addAll(_verifyConstructors(other, publicOnly: publicOnly, strict: strict));

    if (conflicts.isEmpty) return SuccessfulImplementation();
    return ImplementationConflict(other.name, conflicts: conflicts);
  }

  List<InterfaceConflict> _verifyFieldsAndMethods(
    ClassElement other, {
    bool publicOnly = _publicOnlyDefault,
    bool strict = _strictModeDefault,
  }) {
    List<InterfaceConflict> conflicts = [];

    Map<Name, ExecutableElement> expected = InheritanceManager3().getInterface(other).map;
    Map<Name, ExecutableElement> actual = InheritanceManager3().getInterface(this).map;

    for (var name in expected.keys) {
      if (publicOnly && !name.isPublic) continue;

      if (actual[name] == null) {
        conflicts.add(MissingElementConflict(name.name));
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
    bool strict = _strictModeDefault,
  }) {
    List<InterfaceConflict> conflicts = [];

    for (var expected in other.constructors) {
      if (publicOnly && !expected.isPublic) continue;

      var matches = constructors.where((element) => element.name == expected.name);
      if (matches.length != 1) {
        if (matches.isEmpty) {
          conflicts.add(MissingElementConflict(expected.name));
        }
        if (matches.length > 1) {
          conflicts.add(DuplicateElementConflict(expected.name));
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

extension ImplementsElement on ExecutableElement {
  ImplementationResult implementsElement(ExecutableElement other, {bool strict = _strictModeDefault}) {
    List<InterfaceConflict> conflicts = [];

    conflicts.addAll(_verifyReturnType(other));
    if (other.parameters.isNotEmpty) conflicts.addAll(_verifyParameterList(other, strict: strict));

    if (conflicts.isEmpty) return SuccessfulImplementation();
    return ImplementationConflict(other.name, conflicts: conflicts);
  }

  List<InterfaceConflict> _verifyReturnType(ExecutableElement other) {
    String expectedType = other.returnType.getDisplayString(withNullability: true);
    String actualType = returnType.getDisplayString(withNullability: true);
    return [
      if (expectedType != actualType)
        MismatchedReturnTypeConflict(name: name, expected: expectedType, actual: actualType)
    ];
  }

  List<InterfaceConflict> _verifyParameterList(ExecutableElement other, {bool strict = _strictModeDefault}) {
    List<InterfaceConflict> result = _verifyExistingParameterList(other, strict: strict).toList();
    result.addAll(_verifyNewParameterList(other));
    return result;
  }

  List<InterfaceConflict> _verifyExistingParameterList(ExecutableElement other, {bool strict = _strictModeDefault}) {
    List<ParameterConflict> conflicts = [];

    for (ParameterElement expectedParam in other.parameters) {
      // name only matters for named parameters, positional should match count and type
      var matches = parameters.where((element) => element.name == expectedParam.name);
      if (matches.length != 1) {
        if (matches.isEmpty) {
          conflicts.add(MissingParameterConflict(other.displayName, expectedParam.name));
        }
        if (matches.length > 1) {
          conflicts.add(DuplicateParameterConflict(other.displayName, expectedParam.name));
        }
        continue;
      }

      var actualParam = matches.single;

      // Accept required -> optional change only
      // If strict mode is false, also accept @required annotations -> required keyword change
      if (expectedParam.isOptional && actualParam.isRequired && (strict || !(expectedParam.hasRequired))) {
        conflicts.add(OptionalToRequiredParameterConflict(other.displayName, expectedParam.name));
      }

      // Named/positional type changed
      if (expectedParam.isNamed != actualParam.isNamed) {
        if (expectedParam.isNamed) {
          conflicts.add(NamedToPositionalParameterConflict(other.displayName, expectedParam.name));
        } else {
          conflicts.add(PositionalToNamedParameterConflict(other.displayName, expectedParam.name));
        }
      }
    }

    return conflicts;
  }

  List<InterfaceConflict> _verifyNewParameterList(ExecutableElement other) {
    List<ParameterConflict> conflicts = [];

    Set<String> setExpected = parameters.map(((e) => e.displayName)).toSet();
    Set<String> setActual = other.parameters.map(((e) => e.displayName)).toSet();

    // Use set difference to iterate over all new parameter names
    for (var newParam in setExpected.difference(setActual)) {
      var matches = parameters.where((element) => element.displayName == newParam);
      if (matches.length != 1) {
        if (matches.isEmpty) {
          conflicts.add(MissingParameterConflict(other.displayName, newParam));
        }
        if (matches.length > 1) {
          conflicts.add(DuplicateParameterConflict(other.displayName, newParam));
        }
        continue;
      }

      var actualParam = matches.single;

      // New required arguments are a breaking change
      if (actualParam.isRequired) {
        conflicts.add(NewRequiredParameterConflict(other.displayName, newParam));
      }
    }

    return conflicts;
  }
}
