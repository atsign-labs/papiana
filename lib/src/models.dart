abstract class Conflict {
  String get message;
}

class MissingClassConflict implements Conflict {
  final String name;

  const MissingClassConflict(this.name);

  @override
  String get message => 'No implementation for the class "$name" was found.';
}

class DuplicateClassConflict implements Conflict {
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

class InterfaceConflict implements Conflict {
  @override
  // TODO: implement message
  String get message => throw UnimplementedError();
}

class MissingElement implements InterfaceConflict {
  final String name;
  const MissingElement(this.name);

  @override
  String get message => 'Element "$name" is missing from the interface.';
}

class MismatchedReturnType implements InterfaceConflict {
  final String name;
  final String expected;
  final String actual;

  MismatchedReturnType({required this.name, required this.expected, required this.actual});

  @override
  String get message => 'Element "$name" has an incorrect return type, expected "$expected", got "$actual".';
}

abstract class ParameterConflict implements InterfaceConflict {
  abstract final String name;
}

class MissingParameterConflict implements ParameterConflict {
  @override
  final String name;

  MissingParameterConflict(this.name);

  @override
  String get message => 'Missing parameter, expected "$name".';
}

class DuplicateParameterConflict implements ParameterConflict {
  @override
  final String name;

  DuplicateParameterConflict(this.name);

  @override
  String get message => 'Duplicate parameter, expected only one of "$name".';
}

class OptionalToRequiredParameterConflict implements ParameterConflict {
  @override
  final String name;

  OptionalToRequiredParameterConflict(this.name);

  @override
  String get message => 'Previously optional parameter "$name" is now required, causing a breaking change.';
}

class NamedToPositionalParameterConflict implements ParameterConflict {
  @override
  final String name;

  NamedToPositionalParameterConflict(this.name);

  @override
  String get message => 'Previously named parameter "$name" is now positional, causing a breaking change.';
}

class PositionalToNamedParameterConflict implements ParameterConflict {
  @override
  final String name;

  PositionalToNamedParameterConflict(this.name);

  @override
  String get message => 'Previously positional parameter "$name" is now named, causing a breaking change.';
}

class NewRequiredParameterConflict implements ParameterConflict {
  @override
  final String name;

  NewRequiredParameterConflict(this.name);

  @override
  String get message => 'New parameter "$name" is required, causing a breaking change.';
}
