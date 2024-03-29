import 'dart:io';

class PubspecException implements Exception {
  @override
  String toString() => 'pubspec.yaml not found, make sure the root of the package is provided';
}

class PackageDownloadException implements Exception {
  final String package;
  final String? version;

  PackageDownloadException(this.package, {this.version});

  @override
  String toString() => 'Failed to download the package "$package"${version == null ? '' : ' $version'}.';
}

class PubGetException implements Exception {
  final ProcessResult result;

  PubGetException(this.result);

  @override
  String toString() => 'Failed to run "dart pub get" - exited with ${result.exitCode}';
}

class AnalysisException implements Exception {
  final String message;

  AnalysisException(this.message);

  @override
  String toString() => message;
}
