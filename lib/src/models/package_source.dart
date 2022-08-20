import 'dart:async';
import 'dart:convert';

import 'package:pana/pana.dart';
import 'package:papiana/src/models/exceptions.dart';
import 'package:papiana/src/util/constants.dart';
import 'package:papiana/src/util/path_util.dart';
import 'package:http/http.dart' as http;

abstract class PackageSource {
  FutureOr<String> get packagePath;
}

class LocalPackageSource implements PackageSource {
  @override
  final String packagePath;

  const LocalPackageSource(this.packagePath);
}

class HostedPackageSource implements PackageSource {
  final String name;
  final String? version;
  final String hostedUrl;

  HostedPackageSource(this.name, {this.version, this.hostedUrl = defaultHostedUrl});

  final Completer<String> _completer = Completer();
  bool _isStarted = false;

  @override
  Future<String> get packagePath async {
    if (!_isStarted) {
      _isStarted = true;
      _completer.complete(_downloadPackage());
    }
    return _completer.future;
  }

  Future<String> _downloadPackage() async {
    if(_completer.isCompleted) return _completer.future;

    String destination = await _getDownloadLocation();

    try {
      await downloadPackage(name, version, destination: destination, pubHostedUrl: hostedUrl);
    } catch (e) {
      throw PackageDownloadException(name, version: version);
    }

    return destination;
  }

  Future<String> _getDownloadLocation() async {
    String? version = this.version;
    final pubHostedUri = Uri.parse(hostedUrl);
    if (version == null) {
      final versionsUri = pubHostedUri.replace(path: '/api/packages/$name');
      final versionsJson = jsonDecode(await http.read(versionsUri));
      version = versionsJson['latest']['version'] as String;
    }

    return buildPath(
      getCache(),
      pubHostedUri.host,
      '$name-$version',
    );
  }
}
