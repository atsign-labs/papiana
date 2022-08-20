import 'package:analyzer/dart/element/element.dart';

abstract class Conflict {
  String get message;
  Element get expected;
}

abstract class ClassConflict implements Conflict {}

class MissingClassConflict implements ClassConflict {
  @override
  final ClassElement expected;

  const MissingClassConflict(this.expected);

  @override
  String get message => 'No implementation for the class "${expected.name}" was found.';
}

class DuplicateClassConflict implements ClassConflict {
  @override
  final ClassElement expected;

  const DuplicateClassConflict(this.expected);

  @override
  String get message => 'Found duplicate implementations for the class "${expected.name}".';
}

abstract class ImplementationResult {}

class SuccessfulImplementation implements ImplementationResult {}

class ImplementationConflict implements Conflict, ImplementationResult {
  @override
  final Element expected;
  final List<InterfaceConflict> conflicts;

  const ImplementationConflict(this.expected, {this.conflicts = const []});

  @override
  String get message => 'Class ${expected.name} does not fully implement the expected interface.';
}

abstract class InterfaceConflict implements Conflict {}

class MissingElementConflict implements InterfaceConflict {
  @override
  final ExecutableElement expected;

  const MissingElementConflict(this.expected);

  @override
  String get message => 'Element "${expected.name}" is missing from the interface.';
}

class DuplicateElementConflict implements InterfaceConflict {
  @override
  final ExecutableElement expected;

  const DuplicateElementConflict(this.expected);

  @override
  String get message => 'Element "${expected.name}" is duplicated on the interface.';
}

class MismatchedElementTypeConflict implements InterfaceConflict {
  @override
  final ExecutableElement expected;

  const MismatchedElementTypeConflict(this.expected);

  @override
  String get message =>
      'Element "${expected.name}" was expected to be a ${(expected is MethodElement) ? 'method' : 'getter/setter'}.';
}

class MismatchedReturnTypeConflict implements InterfaceConflict {
  @override
  final ExecutableElement expected;

  const MismatchedReturnTypeConflict(this.expected);

  @override
  String get message => 'Element "${expected.name}" has an incorrect return type, expected "${expected.returnType}".';
}

abstract class ParameterConflict implements InterfaceConflict {
  @override
  abstract final ParameterElement expected;
  abstract final ExecutableElement parent;
}

class MissingParameterConflict implements ParameterConflict {
  @override
  final ExecutableElement parent;

  @override
  final ParameterElement expected;

  const MissingParameterConflict(this.parent, this.expected);

  @override
  String get message => 'Missing parameter on "${parent.name}", expected "${expected.displayName}".';
}

class DuplicateParameterConflict implements ParameterConflict {
  @override
  final ExecutableElement parent;

  @override
  final ParameterElement expected;

  const DuplicateParameterConflict(this.parent, this.expected);

  @override
  String get message => 'Duplicate parameter on "${parent.name}", expected only one of "${expected.displayName}".';
}

class MismatchedParameterTypeConflict implements ParameterConflict {
  @override
  final ExecutableElement parent;

  @override
  final ParameterElement expected;

  const MismatchedParameterTypeConflict(this.parent, this.expected);

  @override
  String get message =>
      'Parameter "${expected.displayName}" on "${parent.name}" has an incorrect type, expected "${expected.type}".';
}

class OptionalToRequiredParameterConflict implements ParameterConflict {
  @override
  final ExecutableElement parent;

  @override
  final ParameterElement expected;

  const OptionalToRequiredParameterConflict(this.parent, this.expected);

  @override
  String get message =>
      'Previously optional parameter "${expected.displayName}" on "${parent.name}" is now required, causing a breaking change.';
}

class RequiredToOptionalParameterConflict implements ParameterConflict {
  @override
  final ExecutableElement parent;

  @override
  final ParameterElement expected;

  const RequiredToOptionalParameterConflict(this.parent, this.expected);

  @override
  String get message =>
      'Previously required parameter "${expected.displayName}" on "${parent.name}" is now optional, causing a breaking change.';
}

class MismatchedPositionalCountInNamedParameterConflict implements InterfaceConflict {
  @override
  final ExecutableElement expected;

  const MismatchedPositionalCountInNamedParameterConflict(this.expected);

  @override
  String get message =>
      'The number of positional arguments in "${expected.name}" has changed, expected "${expected.parameters.where((element) => element.isPositional).length}".';
}

class NamedToPositionalParameterConflict implements ParameterConflict {
  @override
  final ExecutableElement parent;

  @override
  final ParameterElement expected;

  const NamedToPositionalParameterConflict(this.parent, this.expected);

  @override
  String get message =>
      'Previously named parameter "${expected.displayName}" on "${parent.name}" is now positional, causing a breaking change.';
}

class PositionalToNamedParameterConflict implements ParameterConflict {
  @override
  final ExecutableElement parent;

  @override
  final ParameterElement expected;

  const PositionalToNamedParameterConflict(this.parent, this.expected);

  @override
  String get message =>
      'Previously positional parameter "${expected.displayName}" on "${parent.name}" is now named, causing a breaking change.';
}

class NewRequiredParameterConflict implements ParameterConflict {
  @override
  final ExecutableElement parent;

  @override
  final ParameterElement expected;

  const NewRequiredParameterConflict(this.parent, this.expected);

  @override
  String get message =>
      'New required parameter "${expected.displayName}" on "${parent.name}, causes a breaking change.';
}
