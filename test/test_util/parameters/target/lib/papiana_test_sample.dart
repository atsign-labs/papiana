class MyInterface {
  // positional parameter - type change
  void positional(int pos) {}

  // positional parameter - optional to required
  void positional2(String pos) {}

  // positional parameter - change names (allowed)
  void positional3(String pos1) {}

  // positional parameter - change position
  void positional4(int pos2, String pos) {}

  // named parameter - type change
  void named({required int nam}) {}

  // named parameter - optional to required
  void named2({required String nam}) {}

  // named parameter - change names
  void named3({required String nam1}) {}

  // named parameter - change position (allowed)
  void named4({required int nam2, required String nam}) {}

  void mixed(String pos, int pos2, {required String nam, required int nam2}) {}
}
