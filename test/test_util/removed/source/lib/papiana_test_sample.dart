// ENTIRE CLASS //

class MyClass {}

// INTERFACE ELEMENTS //

class MyInterface {
  // INSTANCE //

  // An instance function
  void myFunc() {}

  // An instance variable
  String hello = 'hello';

  String _world = 'world';

  // An instance getter
  String get world => _world;

  // An instance setter
  set world(String world) => _world = world;

  // STATIC //
  //TODO

  // A static function
  static void myStaticFunc() {}

  // A static variable
  static String staticHello = 'hello';

  static String _staticWorld = 'world';

  // A static getter
  static String get staticWorld => _staticWorld;

  // A static setter
  static set staticWorld(String staticWorld) => _staticWorld = staticWorld;
}

// CONSTRUCTORS //

class MyInterface2 {
  // Empty unnamed constructor (allowed)
  MyInterface2();

  // Named constructor
  MyInterface2.myConstructor();

  // Named factory
  factory MyInterface2.factoryFunction() => MyInterface2();
}

class MyInterface3 {
  MyInterface3._();

  // Empty unnamed factory (allowed)
  factory MyInterface3() => MyInterface3._();
}

class MyInterface4 {
  // Unnamed constructor
  MyInterface4(String withArg);
}

class MyInterface5 {
  MyInterface5._(String withArg);

  // Unnamed factory
  factory MyInterface5(String withArg) => MyInterface5._(withArg);
}
