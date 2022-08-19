abstract class Conflict {
  String get message;
}

abstract class ClassConflict implements Conflict {}

class MissingClassConflict implements ClassConflict {
  final String name;

  const MissingClassConflict(this.name);

  @override
  String get message => 'No implementation for the class "$name" was found.';
}

class DuplicateClassConflict implements ClassConflict {
  final String name;
  final int count;

  const DuplicateClassConflict(this.name, this.count);

  @override
  String get message => 'Found duplicate implementations for the class "$name" ($count total).';
}

abstract class ImplementationResult {}

class SuccessfulImplementation implements ImplementationResult {}

class ImplementationConflict implements Conflict, ImplementationResult {
  final String name;
  final List<InterfaceConflict> conflicts;

  const ImplementationConflict(this.name, {this.conflicts = const []});

  @override
  String get message => 'Class $name does not fully implement the expected interface.';
}

abstract class InterfaceConflict implements Conflict {}

class MissingElementConflict implements InterfaceConflict {
  final String name;

  const MissingElementConflict(this.name);

  @override
  String get message => 'Element "$name" is missing from the interface.';
}

class DuplicateElementConflict implements InterfaceConflict {
  final String name;

  const DuplicateElementConflict(this.name);

  @override
  String get message => 'Element "$name" is duplicated on the interface.';
}

class MismatchedReturnTypeConflict implements InterfaceConflict {
  final String name;
  final String expected;
  final String actual;

  const MismatchedReturnTypeConflict({required this.name, required this.expected, required this.actual});

  @override
  String get message => 'Element "$name" has an incorrect return type, expected "$expected", got "$actual".';
}

abstract class ParameterConflict implements InterfaceConflict {
  abstract final String parameter;
  abstract final String name;
}

class MissingParameterConflict implements ParameterConflict {
  @override
  final String name;

  @override
  final String parameter;

  const MissingParameterConflict(this.name, this.parameter);

  @override
  String get message => 'Missing parameter on "$name", expected "$parameter".';
}

class DuplicateParameterConflict implements ParameterConflict {
  @override
  final String name;

  @override
  final String parameter;

  const DuplicateParameterConflict(this.name, this.parameter);

  @override
  String get message => 'Duplicate parameter on "$name", expected only one of "$parameter".';
}

class OptionalToRequiredParameterConflict implements ParameterConflict {
  @override
  final String name;

  @override
  final String parameter;

  const OptionalToRequiredParameterConflict(this.name, this.parameter);

  @override
  String get message => 'Previously optional parameter "$parameter" on "$name" is now required, causing a breaking change.';
}

class NamedToPositionalParameterConflict implements ParameterConflict {
  @override
  final String name;

  @override
  final String parameter;

  const NamedToPositionalParameterConflict(this.name, this.parameter);

  @override
  String get message => 'Previously named parameter "$parameter" on "$name" is now positional, causing a breaking change.';
}

class PositionalToNamedParameterConflict implements ParameterConflict {
  @override
  final String name;

  @override
  final String parameter;

  const PositionalToNamedParameterConflict(this.name, this.parameter);

  @override
  String get message => 'Previously positional parameter "$parameter" on "$name" is now named, causing a breaking change.';
}

class NewRequiredParameterConflict implements ParameterConflict {
  @override
  final String name;

  @override
  final String parameter;

  const NewRequiredParameterConflict(this.name, this.parameter);

  @override
  String get message => 'New parameter "$parameter" on "$name" is required, causing a breaking change.';
}
