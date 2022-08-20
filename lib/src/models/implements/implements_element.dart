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
}
