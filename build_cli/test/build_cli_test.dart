// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:build_cli/build_cli.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:source_gen_test/source_gen_test.dart';
import 'package:test/test.dart';

Future<void> main() async {
  const generator = CliGenerator();
  final libraryReader = await initializeLibraryReaderForDirectory(
    'test/test_input',
    'test_input.dart',
  );

  initializeBuildLogTracking();

  group('integration tests', () {
    testAnnotatedElements(
      libraryReader,
      generator,
      expectedAnnotatedTests: [
        'AllowedHelpKeyNoAllowed',
        'AllowedHelpKeyNotInAllowed',
        'AnnotatedCommandNoParser',
        'AnnotatedCommandWithParser',
        'annotatedMethod',
        'BadConvertReturn',
        'ConvertAsStatic',
        'ConvertOnMulti',
        'DefaultNotInAllowed',
        'DefaultOverride',
        'Empty',
        'EnumStaticGetter',
        'FlagWithAllowed',
        'FlagWithAllowedHelp',
        'FlagWithStringDefault',
        'FlagWithValueHelp',
        'GenericOptions',
        'GenericSubClass',
        'ImplementsInterfaceGetter',
        'LonelyWasParsed',
        'NegatableMultiOption',
        'NegatableOption',
        'NonNullableTypes',
        'OptionalPositionalWithoutField',
        'OverridesAnnotatedSuperField',
        'PrivateCtor',
        'RequiredNamedWithoutField',
        'SpecialNotAnnotated',
        'SubClass',
        'theAnswer',
        'TwoNonDefaultConstructors',
        'UnsupportedFieldType',
        'WithCommand',
      ],
    );
  });

  group('inherited setter-only property', () {
    // Pins current behavior: the inherited setter-only property is collected
    // as a field and then `ArgInfo.fromField` dereferences its missing getter,
    // so the generator crashes with a `TypeError` instead of reporting an
    // `InvalidGenerationSourceError`.
    test('InheritsSetterOnly crashes with TypeError', () {
      expect(
        () =>
            generateForElement(generator, libraryReader, 'InheritsSetterOnly'),
        throwsA(isA<TypeError>()),
      );
    });
  });

  final primaryConstructorsRelease =
      Feature.primary_constructors.releaseVersion;
  final currentSdkVersion = Version.parse(Platform.version.split(' ').first);
  if (primaryConstructorsRelease != null &&
      currentSdkVersion >= primaryConstructorsRelease) {
    final primaryConstructorReader = await initializeLibraryReader({
      'primary_constructor_input.dart': _primaryConstructorInput,
    }, 'primary_constructor_input.dart');

    group('primary constructors', () {
      testAnnotatedElements(
        primaryConstructorReader,
        generator,
        expectedAnnotatedTests: [
          'PrimaryConstructorLargeOptions',
          'PrimaryConstructorOptions',
        ],
      );
    });
  } else {
    test(
      'primary constructors',
      () {},
      skip: 'Requires primary-constructors support in SDK and analyzer.',
    );
  }
}

// Pins current behavior for Dart 3.13 primary constructors. Declaring
// parameters have no field or getter name offset, so they all sort to offset
// `0`. With 32 or fewer fields the (stable) insertion sort keeps declaration
// order; above that `List.sort` is not stable and the parser option order is
// scrambled while the constructor invocation keeps parameter order.
const _primaryConstructorInput = r'''
import 'package:build_cli_annotations/build_cli_annotations.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r"""
T _$badNumberFormat<T extends num>(
  String source,
  String type,
  String argName,
) => throw FormatException(
  'Cannot parse "$source" into `$type` for option "$argName".',
);

PrimaryConstructorOptions _$parsePrimaryConstructorOptionsResult(
  ArgResults result,
) => PrimaryConstructorOptions(
  name: result['name'] as String,
  count: result['count'] != null
      ? int.tryParse(result['count'] as String) ??
            _$badNumberFormat(result['count'] as String, 'int', 'count')
      : null,
)..bodyField = result['body-field'] as String?;

ArgParser _$populatePrimaryConstructorOptionsParser(ArgParser parser) => parser
  ..addOption('name')
  ..addOption('count')
  ..addOption('body-field');

final _$parserForPrimaryConstructorOptions =
    _$populatePrimaryConstructorOptionsParser(ArgParser());

PrimaryConstructorOptions parsePrimaryConstructorOptions(List<String> args) {
  final result = _$parserForPrimaryConstructorOptions.parse(args);
  return _$parsePrimaryConstructorOptionsResult(result);
}
""")
@CliOptions()
class PrimaryConstructorOptions({
  required final String name,
  final int? count,
}) {
  String? bodyField;
}

@ShouldGenerate(r"""
PrimaryConstructorLargeOptions _$parsePrimaryConstructorLargeOptionsResult(
  ArgResults result,
) =>
    PrimaryConstructorLargeOptions(
        param01: result['param01'] as bool,
        param02: result['param02'] as bool,
        param03: result['param03'] as bool,
        param04: result['param04'] as bool,
        param05: result['param05'] as bool,
        param06: result['param06'] as bool,
        param07: result['param07'] as bool,
        param08: result['param08'] as bool,
        param09: result['param09'] as bool,
        param10: result['param10'] as bool,
        param11: result['param11'] as bool,
        param12: result['param12'] as bool,
        param13: result['param13'] as bool,
        param14: result['param14'] as bool,
        param15: result['param15'] as bool,
        param16: result['param16'] as bool,
        param17: result['param17'] as bool,
        param18: result['param18'] as bool,
        param19: result['param19'] as bool,
        param20: result['param20'] as bool,
        param21: result['param21'] as bool,
        param22: result['param22'] as bool,
        param23: result['param23'] as bool,
        param24: result['param24'] as bool,
        param25: result['param25'] as bool,
        param26: result['param26'] as bool,
        param27: result['param27'] as bool,
        param28: result['param28'] as bool,
        param29: result['param29'] as bool,
        param30: result['param30'] as bool,
        param31: result['param31'] as bool,
        param32: result['param32'] as bool,
        param33: result['param33'] as bool,
        param34: result['param34'] as bool,
        param35: result['param35'] as bool,
        param36: result['param36'] as bool,
        param37: result['param37'] as bool,
        param38: result['param38'] as bool,
        param39: result['param39'] as bool,
        param40: result['param40'] as bool,
      )
      ..bodyA = result['body-a'] as String?
      ..bodyB = result['body-b'] as String?;

ArgParser _$populatePrimaryConstructorLargeOptionsParser(ArgParser parser) =>
    parser
      ..addFlag('param14')
      ..addFlag('param02')
      ..addFlag('param03')
      ..addFlag('param04')
      ..addFlag('param05')
      ..addFlag('param06')
      ..addFlag('param07')
      ..addFlag('param08')
      ..addFlag('param09')
      ..addFlag('param10')
      ..addFlag('param11')
      ..addFlag('param12')
      ..addFlag('param13')
      ..addFlag('param01')
      ..addFlag('param15')
      ..addFlag('param16')
      ..addFlag('param17')
      ..addFlag('param18')
      ..addFlag('param19')
      ..addFlag('param20')
      ..addFlag('param21')
      ..addFlag('param22')
      ..addFlag('param23')
      ..addFlag('param24')
      ..addFlag('param25')
      ..addFlag('param26')
      ..addFlag('param27')
      ..addFlag('param40')
      ..addFlag('param29')
      ..addFlag('param30')
      ..addFlag('param31')
      ..addFlag('param32')
      ..addFlag('param33')
      ..addFlag('param34')
      ..addFlag('param35')
      ..addFlag('param36')
      ..addFlag('param37')
      ..addFlag('param38')
      ..addFlag('param39')
      ..addFlag('param28')
      ..addOption('body-a')
      ..addOption('body-b');

final _$parserForPrimaryConstructorLargeOptions =
    _$populatePrimaryConstructorLargeOptionsParser(ArgParser());

PrimaryConstructorLargeOptions parsePrimaryConstructorLargeOptions(
  List<String> args,
) {
  final result = _$parserForPrimaryConstructorLargeOptions.parse(args);
  return _$parsePrimaryConstructorLargeOptionsResult(result);
}
""")
@CliOptions()
class PrimaryConstructorLargeOptions({
  required final bool param01,
  required final bool param02,
  required final bool param03,
  required final bool param04,
  required final bool param05,
  required final bool param06,
  required final bool param07,
  required final bool param08,
  required final bool param09,
  required final bool param10,
  required final bool param11,
  required final bool param12,
  required final bool param13,
  required final bool param14,
  required final bool param15,
  required final bool param16,
  required final bool param17,
  required final bool param18,
  required final bool param19,
  required final bool param20,
  required final bool param21,
  required final bool param22,
  required final bool param23,
  required final bool param24,
  required final bool param25,
  required final bool param26,
  required final bool param27,
  required final bool param28,
  required final bool param29,
  required final bool param30,
  required final bool param31,
  required final bool param32,
  required final bool param33,
  required final bool param34,
  required final bool param35,
  required final bool param36,
  required final bool param37,
  required final bool param38,
  required final bool param39,
  required final bool param40,
}) {
  String? bodyA;
  String? bodyB;
}
''';
