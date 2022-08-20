library test_directory;

import 'dart:mirrors';
import 'package:path/path.dart' as path;

final String testDirectory =
    path.dirname((reflectClass(_TestUtils).owner as LibraryMirror).uri.path);

class _TestUtils {}