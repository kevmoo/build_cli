import 'dart:async';

import 'package:build/build.dart' show BuildStep, AssetId;
import 'package:source_gen/source_gen.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

final _upperCase = new RegExp('[A-Z]');
final _lowestSdkSupported = new Version.parse('2.0.0-dev.48');

String kebab(String input) => input.replaceAllMapped(_upperCase, (match) {
      var lower = match.group(0).toLowerCase();

      if (match.start > 0) {
        lower = '-$lower';
      }

      return lower;
    });

Future validateSdkConstraint(BuildStep buildStep) async {
  if (buildStep == null) {
    // Not running as part of a "build" – noop.
    return;
  }
  var uri = 'asset:${buildStep.inputId.package}/pubspec.yaml';
  var thing = await buildStep.readAsString(new AssetId.resolve(uri));

  var pubSpecYaml = loadYaml(thing, sourceUrl: uri) as YamlMap;

  var environment = pubSpecYaml['environment'];

  if (environment is YamlMap) {
    var sdk = environment['sdk'];
    if (sdk is String) {
      var constraint = new VersionConstraint.parse(sdk);

      if (constraint.allowsAny(
          new VersionRange(max: _lowestSdkSupported, includeMax: false))) {
        throw new InvalidGenerationSourceError(
            'The SDK constraint on `package:${buildStep.inputId.package}` is not valid: `$constraint`. '
            'The minimum supported Dart SDK must be `>=$_lowestSdkSupported`.');
      }
    }
  }
}
