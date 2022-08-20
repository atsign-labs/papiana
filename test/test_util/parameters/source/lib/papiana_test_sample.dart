class MyInterface {
  // positional parameter - type change
  void positional(String pos) {}

  // positional parameter - optional to required
  void positional2([String? pos]) {}

  // positional parameter - change names (allowed)
  void positional3(String pos) {}

  // positional parameter - change position
  void positional4(String pos, int pos2) {}

  // named parameter - type change
  void named({required String nam}) {}

  // named parameter - optional to required
  void named2({String? nam}) {}

  // named parameter - change names
  void named3({required String nam}) {}

  // named parameter - change position (allowed)
  void named4({required String nam, required int nam2}) {}

  // mixed parameters
  void mixed(String pos, int pos2, {required String nam, required int nam2}) {}
}
