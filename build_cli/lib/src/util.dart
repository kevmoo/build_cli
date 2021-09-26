import 'dart:async';

import 'package:build/build.dart' show BuildStep, AssetId;
import 'package:pub_semver/pub_semver.dart';
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

final _lowestSdkSupported = Version.parse('2.0.0');

Future validateSdkConstraint(BuildStep buildStep) async {
  if (buildStep.toString().contains('_MockBuildStep')) {
    // This is a throw-away class from `source_gen_test` – ignore!
    return;
  }
  final uri = Uri.parse('asset:${buildStep.inputId.package}/pubspec.yaml');
  final thing = await buildStep.readAsString(AssetId.resolve(uri));

  final pubSpecYaml = loadYaml(thing, sourceUrl: uri) as YamlMap;

  final environment = pubSpecYaml['environment'];

  if (environment is YamlMap) {
    final sdk = environment['sdk'];
    if (sdk is String) {
      final constraint = VersionConstraint.parse(sdk);

      if (constraint.allowsAny(VersionRange(max: _lowestSdkSupported))) {
        throw InvalidGenerationSourceError(
            'The SDK constraint on `package:${buildStep.inputId.package}` is '
            'not valid: `$constraint`. '
            'The minimum supported Dart SDK must be `>=$_lowestSdkSupported`.');
      }
    }
  }
}
