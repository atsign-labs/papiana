part of '../implements.dart';

extension ImplementsParameters on ExecutableElement {
  ImplementationResult implementsParameters(ExecutableElement other, {bool strict = _strictDefault}) {
    List<InterfaceConflict> conflicts = [];

    if (other.parameters.any((element) => element.isNamed)) {
      conflicts.addAll(_verifyNamed(other, strict: strict));
    } else {
      conflicts.addAll(_verifyPositional(other, strict: strict));
    }

    if (conflicts.isEmpty) return SuccessfulImplementation();
    return ImplementationConflict(other, conflicts: conflicts);
  }

  List<InterfaceConflict> _verifyNamed(ExecutableElement other, {bool strict = _strictDefault}) {
    List<InterfaceConflict> conflicts = [];

    // 1. Verify Positional Parameters

    if (other.parameters.any((element) => element.isOptionalPositional)) {
      // Something is very wrong, this shouldn't be possible
      // cant have named and optionalPositional
      throw AnalysisException('Cannot have both optional-positional and named parameters in the same signature.');
    }

    int positionalCount = other.parameters.where((element) => element.isPositional).length;
    int newPositionalCount = parameters.where((element) => element.isPositional).length;

    if (positionalCount != newPositionalCount) {
      return [MismatchedPositionalCountInNamedParameterConflict(other)];
    }

    for (int i = 0; i < positionalCount; i++) {
      ParameterElement expected = other.parameters[i];
      ParameterElement actual = parameters[i];

      if (actual.isOptional) {
        conflicts.add(RequiredToOptionalParameterConflict(other, expected));
      }

      if (actual.isNamed) {
        conflicts.add(PositionalToNamedParameterConflict(other, expected));
      }

      if (expected.type.getDisplayString(withNullability: true) !=
          actual.type.getDisplayString(withNullability: true)) {
        conflicts.add(MismatchedParameterTypeConflict(other, expected));
      }
    }

    // 2. Verify Named Parameters

    Iterable<ParameterElement> named = other.parameters.where((element) => element.isNamed);

    for (ParameterElement expected in named) {
      var matches = parameters.where((element) => element.name == expected.name);
      if (matches.length != 1) {
        if (matches.isEmpty) {
          conflicts.add(MissingParameterConflict(other, expected));
        }
        if (matches.length > 1) {
          conflicts.add(DuplicateParameterConflict(other, expected));
        }
        continue;
      }

      var actual = matches.single;

      String expectedType = expected.type.getDisplayString(withNullability: true);
      String actualType = actual.type.getDisplayString(withNullability: true);

      if (expectedType != actualType) {
        conflicts.add(MismatchedParameterTypeConflict(other, expected));
        continue;
      }

      // Accept required -> optional change only
      // If strict mode is false, also accept @required annotations -> required keyword change
      if (expected.isOptional && actual.isRequired && (strict || !(expected.hasRequired))) {
        conflicts.add(OptionalToRequiredParameterConflict(other, expected));
      }

      if (actual.isPositional) {
        conflicts.add(NamedToPositionalParameterConflict(other, expected));
        continue;
      }
    }

    // 3. Verify New Parameters

    Set<String> setExpected = parameters.map(((e) => e.displayName)).toSet();
    Set<String> setActual = other.parameters.map(((e) => e.displayName)).toSet();

    // Use set difference to iterate over all new parameter names
    for (var newParamName in setExpected.difference(setActual)) {
      var matches = parameters.where((element) => element.name == newParamName);

      if (matches.length > 1) {
        conflicts.add(DuplicateParameterConflict(other, matches.first));
        continue;
      }

      var actual = matches.single;

      // New required arguments are a breaking change
      if (actual.isRequired) {
        conflicts.add(NewRequiredParameterConflict(other, actual));
      }
    }
    return conflicts;
  }

  List<ParameterConflict> _verifyPositional(ExecutableElement other, {bool strict = _strictDefault}) {
    List<ParameterConflict> conflicts = [];

    // 1. Verify Old Parameters
    for (int i = 0; i < other.parameters.length; i++) {
      ParameterElement expected = other.parameters[i];
      ParameterElement actual = parameters[i];

      String expectedType = expected.type.getDisplayString(withNullability: true);
      String actualType = actual.type.getDisplayString(withNullability: true);

      if (expectedType != actualType) {
        conflicts.add(MismatchedParameterTypeConflict(other, expected));
        continue;
      }

      // Accept required -> optional change only
      // If strict mode is false, also accept @required annotations -> required keyword change
      if (expected.isOptional && actual.isRequired && (strict || !(expected.hasRequired))) {
        conflicts.add(OptionalToRequiredParameterConflict(other, expected));
      }
    }

    // 2. Verify New Parameters
    for (int i = other.parameters.length; i < parameters.length; i++) {
      ParameterElement actual = parameters[i];

      // New required arguments are a breaking change
      if (actual.isRequired) {
        conflicts.add(NewRequiredParameterConflict(other, actual));
      }
    }

    return conflicts;
  }
}
