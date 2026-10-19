import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart' show AssetId, BuildStep;
import 'package:pub_semver/pub_semver.dart';
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

Never throwBugFound(FieldElement element) => throwUnsupported(
  element,
  "You've hit a bug in build_cli!",
  todo:
      'Please rerun your build with --verbose and file as issue '
      'with the stace trace.',
);

Never throwUnsupported(FieldElement element, String message, {String? todo}) =>
    throw InvalidGenerationSourceError(
      'Could not handle field `${element.displayName}`. $message',
      element: element,
      todo: todo ?? '',
    );

final _lowestSdkSupported = Version.parse('2.0.0');

String baseReleaseVersion(String version) =>
    version.split(RegExp(r'[-+]')).first;

Future<void> validateSdkConstraint(BuildStep buildStep) async {
  if (buildStep.toString().contains('_MockBuildStep')) {
    // This is a throw-away class from `source_gen_test` – ignore!
    return;
  }
  final uri = Uri.parse('asset:${buildStep.inputId.package}/pubspec.yaml');
  final thing = await buildStep.readAsString(AssetId.resolve(uri));

  validatePubspecSdkConstraint(
    thing,
    packageName: buildStep.inputId.package,
    sourceUrl: uri,
  );
}

void validatePubspecSdkConstraint(
  String pubspecContent, {
  required String packageName,
  Uri? sourceUrl,
}) {
  final pubSpecYaml = loadYaml(pubspecContent, sourceUrl: sourceUrl);
  if (pubSpecYaml is! YamlMap) return;

  final environment = pubSpecYaml['environment'];

  if (environment is YamlMap) {
    final sdk = environment['sdk'];
    if (sdk is String) {
      final constraint = VersionConstraint.parse(sdk);

      if (constraint.allowsAny(VersionRange(max: _lowestSdkSupported))) {
        throw InvalidGenerationSourceError(
          'The SDK constraint on `package:$packageName` is '
          'not valid: `$constraint`. '
          'The minimum supported Dart SDK must be `>=$_lowestSdkSupported`.',
        );
      }
    }
  }
}
