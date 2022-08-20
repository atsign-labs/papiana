import 'dart:io';

import 'package:papiana/src/models/conflicts.dart';

void printConflicts(Iterable<Conflict> conflicts) {
  List<String> conflictLines = [];

    for (var outer in conflicts) {
      conflictLines.add('\t${outer.message}');

      if (outer is ImplementationConflict) {
        for (var inner in outer.conflicts) {
          conflictLines.add('\t\t${inner.message}');
        }
      }
    }

    stdout.writeAll(conflictLines, '\n');
    stdout.writeln();
}