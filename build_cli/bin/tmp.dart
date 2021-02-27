import 'package:args/args.dart';

void main() {
  var parser = ArgParser();
  parser.addOption('mode', defaultsTo: 'extra-fancy');
  parser.addFlag('verbose', defaultsTo: true);
  var results = parser.parse(['something', 'else']);

  print(results['mode']); // debug
  print(results['verbose']); // true
}