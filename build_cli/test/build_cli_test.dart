// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:build_cli/build_cli.dart';
import 'package:source_gen_test/source_gen_test.dart';
import 'package:test/test.dart';

Future<void> main() async {
  const generator = CliGenerator();
  final libraryReader = await initializeLibraryReaderForDirectory(
    'test/test_input',
    'test_input.dart',
  );

  group('integration tests', () {
    initializeBuildLogTracking();
    testAnnotatedElements(
      libraryReader,
      generator,
      expectedAnnotatedTests: [
        'AnnotatedCommandNoParser',
        'AnnotatedCommandWithParser',
        'annotatedMethod',
        'BadConvertParam',
        'BadConvertReturn',
        'ConvertAsStatic',
        'ConvertOnMulti',
        'DefaultNotInAllowed',
        'DefaultOverride',
        'Empty',
        'FlagWithAllowed',
        'FlagWithAllowedHelp',
        'FlagWithStringDefault',
        'FlagWithValueHelp',
        'LonelyWasParsed',
        'NegatableMultiOption',
        'NegatableOption',
        'SpecialNotAnnotated',
        'theAnswer',
        'UnknownCtorParamType',
        'UnknownFieldType',
        'UnsupportedFieldType',
        'WithCommand',
      ],
    );
  });
}
