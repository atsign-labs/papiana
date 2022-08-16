import 'package:papiana/papiana.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/inheritance_manager3.dart';
import 'package:papiana/src/models.dart';

extension Implements on ClassElement {
  ImplementationResult implementsClass(ClassElement other, {bool publicOnly = true, bool strict = true}) {
    List<InterfaceConflict> conflicts = [];

    Map<Name, ExecutableElement> otherInterface = InheritanceManager3().getInterface(other).map;
    Map<Name, ExecutableElement> thisInterface = InheritanceManager3().getInterface(this).map;

    for (var elementName in otherInterface.keys) {
      if (publicOnly && !elementName.isPublic) continue;
      if (!thisInterface.containsKey(elementName) || thisInterface[elementName] == null) {
        conflicts.add(MissingElement(elementName.name));
        continue;
      }

      ExecutableElement otherElement = otherInterface[elementName]!;
      ExecutableElement thisElement = thisInterface[elementName]!;

      // Verify getters / return types
      String expectedType = otherElement.returnType.getDisplayString(withNullability: true);
      String actualType = thisElement.returnType.getDisplayString(withNullability: true);
      if (expectedType != actualType) {
        conflicts.add(MismatchedReturnType(name: elementName.name, expected: expectedType, actual: actualType));
      }

      // Verify setters / parameter lists
      List<ParameterElement> expectedParams = otherElement.parameters;
      List<ParameterElement> actualParams = thisElement.parameters;

      // Verify all previous parameters exist in a non-breaking way
      // i.e. The only acceptable change is required -> optional
      for (var expectedParam in expectedParams) {
        var matchingParams = actualParams.where((element) => element.name == expectedParam.name);
        if (matchingParams.length != 1) {
          if (matchingParams.isEmpty) {
            conflicts.add(MissingParameterConflict(elementName.name));
          }
          if (matchingParams.length > 1) {
            conflicts.add(DuplicateParameterConflict(elementName.name));
          }
          continue;
        }

        var actualParam = matchingParams.single;
        // If strict mode is false, accept @required annotations -> required keyword change
        if (expectedParam.isOptional && actualParam.isRequired && (strict || !(expectedParam.hasRequired))) {
          conflicts.add(OptionalToRequiredParameterConflict(elementName.name));
        }
        if (expectedParam.isNamed != actualParam.isNamed) {
          if (expectedParam.isNamed) {
            conflicts.add(NamedToPositionalParameterConflict(elementName.name));
          } else {
            conflicts.add(PositionalToNamedParameterConflict(elementName.name));
          }
        }
      }

      // Verify that all new parameters are optional
      Set<String> setExpected = expectedParams.map(((e) => e.name)).toSet();
      Set<String> setActual = actualParams.map(((e) => e.name)).toSet();
      for (var newParam in setActual.difference(setExpected)) {
        var matchingParams = actualParams.where((element) => element.name == newParam);
        if (matchingParams.length != 1) {
          if (matchingParams.isEmpty) {
            conflicts.add(MissingParameterConflict(newParam));
          }
          if (matchingParams.length > 1) {
            conflicts.add(DuplicateParameterConflict(newParam));
          }
          continue;
        }

        var actualParam = matchingParams.single;
        if (actualParam.isRequired) {
          conflicts.add(NewRequiredParameterConflict(newParam));
        }
      }
    }

    for (ConstructorElement expectedConstructor in other.constructors) {
      // TODO ensure that public constructors do not have breaking changes
    }

    if (conflicts.isEmpty) return SuccessfulImplementation();

    return ImplementationConflict(other.name, conflicts: conflicts);
  }
}
