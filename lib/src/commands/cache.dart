import 'package:args/command_runner.dart';

const _name = 'cache';
const _description = '[COMING SOON] Manipulate the papiana cache.';

class CacheCommand extends Command<int> {
  @override
  String get name => _name;

  @override
  String get description => _description;

  @override
  Future<int> run() async {
    // TODO
    return 0;
  }
}
