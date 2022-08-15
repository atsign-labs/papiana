import 'package:path/path.dart' as path;

String buildPath(String p1, [String? p2, String? p3, String? p4, String? p5]) {
  return path.normalize(path.absolute(path.join(p1, p2, p3, p4, p5)));
}
