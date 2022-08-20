part of '../implements.dart';

extension ImplementsElement on ExecutableElement {
  ImplementationResult implementsElement(ExecutableElement other, {bool strict = _strictDefault}) {
    List<InterfaceConflict> conflicts = [];

    bool isMethod = other is MethodElement;
    bool isConstructor = other is ConstructorElement;

    if (isMethod != this is MethodElement || isConstructor != this is ConstructorElement) {
      conflicts.add(MismatchedElementTypeConflict(other));
    }

    conflicts.addAll(_verifyReturnType(other));

    if ((isMethod || isConstructor) && other.parameters.isNotEmpty) {
      ImplementationResult results = implementsParameters(other);
      if (results is ImplementationConflict) conflicts.addAll(results.conflicts);
    }

    if (conflicts.isEmpty) return SuccessfulImplementation();
    return ImplementationConflict(other, conflicts: conflicts);
  }

  List<InterfaceConflict> _verifyReturnType(ExecutableElement other) {
    String expectedType = other.returnType.getDisplayString(withNullability: true);
    String actualType = returnType.getDisplayString(withNullability: true);
    return [if (expectedType != actualType) MismatchedReturnTypeConflict(other)];
  }

  List<InterfaceConflict> _verifyParameterList(ExecutableElement other, {bool strict = _strictDefault}) {
    List<InterfaceConflict> result = _verifyExistingParameterList(other, strict: strict).toList();
    result.addAll(_verifyNewParameterList(other));
    return result;
  }

  List<InterfaceConflict> _verifyExistingParameterList(ExecutableElement other, {bool strict = _strictDefault}) {
    List<ParameterConflict> conflicts = [];

    for (ParameterElement expectedParam in other.parameters) {
      // name only matters for named parameters, positional should match count and type
      var matches = parameters.where((element) => element.name == expectedParam.name);
      if (matches.length != 1) {
        if (matches.isEmpty) {
          conflicts.add(MissingParameterConflict(other, expectedParam));
        }
        if (matches.length > 1) {
          conflicts.add(DuplicateParameterConflict(other, expectedParam));
        }
        continue;
      }

      var actualParam = matches.single;

      // Accept required -> optional change only
      // If strict mode is false, also accept @required annotations -> required keyword change
      if (expectedParam.isOptional && actualParam.isRequired && (strict || !(expectedParam.hasRequired))) {
        conflicts.add(OptionalToRequiredParameterConflict(other, expectedParam));
      }

      // Named/positional type changed
      if (expectedParam.isNamed != actualParam.isNamed) {
        if (expectedParam.isNamed) {
          conflicts.add(NamedToPositionalParameterConflict(other, expectedParam));
        } else {
          conflicts.add(PositionalToNamedParameterConflict(other, expectedParam));
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
      var matches = parameters.where((element) => element.name == newParam);

      if (matches.length > 1) {
        conflicts.add(DuplicateParameterConflict(other, matches.first));
        continue;
      }

      var actualParam = matches.single;

      // New required arguments are a breaking change
      if (actualParam.isRequired) {
        conflicts.add(NewRequiredParameterConflict(other, actualParam));
      }
    }

    return conflicts;
  }
}
